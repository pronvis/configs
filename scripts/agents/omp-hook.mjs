// Report this Oh My Pi (omp) session's status to the tmux agents view
// (prefix+C) and the status bar, matching what claude/settings.json and
// codex/hooks.json do for the other agents. See scripts/agents/tmux-agent-status.
//
// Unlike those two, omp has no declarative hook config: a hook is a module whose
// default export receives the extension API. Registered persistently in the
// `extensions` config array (see README), or ad hoc with `omp --hook <path>`.
//
// Omp imports the module before its runtime actions (including api.exec) are
// initialized. Report the initial state from session_start instead of directly
// from the extension factory, otherwise the first report can be rejected during
// startup and the session stays invisible until another lifecycle event fires.
//
// `tool_call` is deliberately unused. A tool_call handler that throws or exceeds
// extensionHandlers.toolCallTimeoutMs resolves to {block: true}, which refuses
// the tool call; status reporting must never be able to block work. Every event
// below discards its handler's return value, so a failure here stays cosmetic.

import { spawnSync } from "node:child_process";

const SCRIPT = `${process.env.HOME}/bin/scripts/agents/tmux-agent-status`;
const ARGV = (status) => ["-c", 'exec "$1" "$2" omp </dev/null', "omp-hook", SCRIPT, status];

// stdin is redirected because tmux-agent-status drains it when it is not a tty
// (the Claude Notification payload arrives that way). api.exec gives the child a
// pipe nobody writes to, so without </dev/null its `cat` would never return.
const report = (api, status) => api.exec("bash", ARGV(status)).catch(() => {});

export default function ompTmuxStatus(api) {
	api.on("session_start", () => {
		report(api, "idle");
	});

	// session_shutdown was not observed to fire in print mode, and a session that
	// never deregisters is worse than one that reports late: `idle` entries are
	// exempt from the staleness sweep in agent-sessions, so a ghost omp session
	// would sit in the picker until its pane died. Deregister on process exit as
	// well -- synchronously, because the event loop is already closing by then.
	process.once("exit", () => {
		try {
			spawnSync("bash", ARGV("gone"), { stdio: "ignore" });
		} catch {}
	});

	api.on("input", () => {
		report(api, "working");
	});
	api.on("tool_result", () => {
		report(api, "working");
	});
	api.on("tool_approval_requested", () => {
		report(api, "waiting");
	});
	api.on("tool_approval_resolved", () => {
		report(api, "working");
	});
	api.on("session_stop", () => {
		report(api, "idle");
	});
	api.on("session_shutdown", () => {
		report(api, "gone");
	});
}
