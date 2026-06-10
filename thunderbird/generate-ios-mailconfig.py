#!/usr/bin/env python3
"""Generate an iOS .mobileconfig Mail profile from a Thunderbird prefs.js.

Reads the IMAP account, identity and SMTP settings exported by
export-tb-settings.sh and emits an Apple configuration profile that creates
the same accounts in the iOS Mail app. Passwords are intentionally NOT
included: iOS prompts for each account's password after the profile is
installed. Providers that require OAuth in Thunderbird (Gmail, iCloud,
Yandex) need an app-specific password on iOS, since Apple's Mail payload
only supports password authentication.

Usage:
    python3 generate-ios-mailconfig.py /path/to/profile-files/prefs.js [out.mobileconfig]
"""
import plistlib
import re
import sys
import uuid
from pathlib import Path

PREF_RE = re.compile(r'user_pref\("([^"]+)",\s*(?:"((?:[^"\\]|\\.)*)"|(\d+)|(true|false))\);')

# Thunderbird socketType: 0 = plain, 2 = STARTTLS, 3 = SSL/TLS.
# iOS expresses both 2 and 3 as UseSSL=true (it negotiates per port).
SSL_SOCKET_TYPES = {2, 3}
OAUTH_AUTH_METHOD = 10  # Thunderbird's authMethod value for OAuth2


def parse_prefs(path: Path) -> dict:
    prefs = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = PREF_RE.match(line.strip())
        if not m:
            continue
        key, s, n, b = m.groups()
        if s is not None:
            prefs[key] = s.encode().decode("unicode_escape")
        elif n is not None:
            prefs[key] = int(n)
        else:
            prefs[key] = b == "true"
    if not prefs:
        sys.exit(f"ERROR: no user_pref entries found in {path}")
    return prefs


def collect_accounts(prefs: dict) -> list:
    accounts = []
    for acct in prefs.get("mail.accountmanager.accounts", "").split(","):
        server = prefs.get(f"mail.account.{acct}.server")
        if not server or prefs.get(f"mail.server.{server}.type", "imap") != "imap":
            continue
        sp = f"mail.server.{server}"
        hostname = prefs.get(f"{sp}.hostname")
        if not hostname:
            continue
        identity = prefs.get(f"mail.account.{acct}.identities", "").split(",")[0]
        ip = f"mail.identity.{identity}"
        smtp = prefs.get(f"{ip}.smtpServer")
        mp = f"mail.smtpserver.{smtp}"
        if not smtp or f"{mp}.hostname" not in prefs:
            print(f"note: {acct} has no SMTP server, skipping", file=sys.stderr)
            continue
        accounts.append({
            "description": prefs.get(f"{sp}.name", hostname),
            "full_name": prefs.get(f"{ip}.fullName", ""),
            "email": prefs.get(f"{ip}.useremail", ""),
            "imap_host": hostname,
            "imap_port": prefs.get(f"{sp}.port", 993),
            "imap_ssl": prefs.get(f"{sp}.socketType", 3) in SSL_SOCKET_TYPES,
            "imap_user": prefs.get(f"{sp}.userName", ""),
            "smtp_host": prefs[f"{mp}.hostname"],
            "smtp_port": prefs.get(f"{mp}.port", 465),
            "smtp_ssl": prefs.get(f"{mp}.try_ssl", 3) in SSL_SOCKET_TYPES,
            "smtp_user": prefs.get(f"{mp}.username", ""),
            "oauth_in_tb": prefs.get(f"{sp}.authMethod") == OAUTH_AUTH_METHOD,
        })
    if not accounts:
        sys.exit("ERROR: no IMAP accounts found in prefs.js")
    return accounts


def mail_payload(acc: dict) -> dict:
    return {
        "PayloadType": "com.apple.mail.managed",
        "PayloadVersion": 1,
        "PayloadIdentifier": f"thunderbird.export.mail.{acc['email']}",
        "PayloadUUID": str(uuid.uuid4()),
        "PayloadDisplayName": acc["description"],
        "EmailAccountType": "EmailTypeIMAP",
        "EmailAccountDescription": acc["description"],
        "EmailAccountName": acc["full_name"],
        "EmailAddress": acc["email"],
        "IncomingMailServerHostName": acc["imap_host"],
        "IncomingMailServerPortNumber": acc["imap_port"],
        "IncomingMailServerUseSSL": acc["imap_ssl"],
        "IncomingMailServerUsername": acc["imap_user"],
        "IncomingMailServerAuthentication": "EmailAuthPassword",
        "OutgoingMailServerHostName": acc["smtp_host"],
        "OutgoingMailServerPortNumber": acc["smtp_port"],
        "OutgoingMailServerUseSSL": acc["smtp_ssl"],
        "OutgoingMailServerUsername": acc["smtp_user"],
        "OutgoingMailServerAuthentication": "EmailAuthPassword",
        "OutgoingPasswordSameAsIncomingPassword": True,
        "PreventMove": False,
        "PreventAppSheet": False,
        "disableMailRecentsSyncing": False,
    }


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())
    prefs_path = Path(sys.argv[1])
    if not prefs_path.is_file():
        sys.exit(f"ERROR: {prefs_path} is not a file")
    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else prefs_path.with_name("tb-mail.mobileconfig")

    accounts = collect_accounts(parse_prefs(prefs_path))
    profile = {
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "thunderbird.export.mailprofile",
        "PayloadUUID": str(uuid.uuid4()),
        "PayloadDisplayName": "Thunderbird mail accounts",
        "PayloadDescription": "IMAP accounts exported from Thunderbird",
        "PayloadContent": [mail_payload(a) for a in accounts],
    }
    with out_path.open("wb") as f:
        plistlib.dump(profile, f)

    print(f"Created: {out_path}\n\nAccounts included:")
    for a in accounts:
        note = "  (OAuth in Thunderbird -> use an APP PASSWORD on iOS)" if a["oauth_in_tb"] else ""
        print(f"  - {a['description']}: {a['imap_host']}:{a['imap_port']} / "
              f"{a['smtp_host']}:{a['smtp_port']}{note}")


if __name__ == "__main__":
    main()
