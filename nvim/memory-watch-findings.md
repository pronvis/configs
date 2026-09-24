# Neovim memory watcher findings

The watcher caught large cores, but **none of the seven historical above-threshold events produced an internal dump**. Launchd could not find its `nvim` RPC client. The affected cores' memory contents and cause remain unknown.

| Evidence | Reading |
| --- | --- |
| [July 11 baseline dump](file:///Users/pronvis/.local/state/nvim-leak/report.log) (lines 1–10) | One core reported 11.6 MiB Lua, one 145-line buffer, no extmarks, no LSP clients. No preceding threshold record ties this dump to a large core. |
| [August 6 records](file:///Users/pronvis/.local/state/nvim-leak/report.log) (lines 11–19) | PID 9415: 1507, 1539, 1525 script-labeled MB over 4h 38m 43s. Each socket was found; all three RPC commands failed at executable lookup. |
| [September 18 records](file:///Users/pronvis/.local/state/nvim-leak/report.log) (lines 27–38) | PID 29481: 8648, 7422, 6234, then 3993 MB between 16:50:20 and 16:52:51. RSS **fell by 4655 MB** across these 2m 31s; its prior trajectory is unknown. All four RPC commands failed at executable lookup. |

The labels `MB` are truncated MiB: [the script](../scripts/nvim-mem-watch.sh#L38-L54) divides RSS in KiB by 1024. Its 1500-MiB threshold applies **per `nvim --embed` core**, not across the editors. It records a PID's 512-MiB bucket before attempting the dump, suppresses retries in the same bucket even after failure, and also records crossings **downward**. These are sparse samples, not a continuous trace. A live process check found 25 cores totaling about 1555 MiB, with the largest at 205 MiB; none was near the per-core threshold.

Before the repair, [the launch agent](../launchd/com.pronvis.nvim-mem-watch.plist) had no PATH override. `launchctl print gui/501/com.pronvis.nvim-mem-watch` showed PATH `/usr/bin:/bin:/usr/sbin:/sbin`, while `nvim` lives at `/opt/homebrew/bin/nvim`; an invocation under that PATH failed with exit 127. The old [watcher](../scripts/nvim-mem-watch.sh#L46-L54) also mislabeled every command failure as `core unresponsive — likely blocked allocating`. Executable lookup failed before any RPC was attempted.

**Repaired on September 24:** the template and installed launch agent now include the Homebrew binary directories in PATH. A first isolated watcher run exposed another blocker: `--remote-send` returned success but produced no dump for an embedded core with no UI. The watcher now uses synchronous `--remote-expr` to execute the Lua dumper inside that core and reports RPC failure without guessing why.

An isolated end-to-end run used a real scratch `nvim --embed` process, its real socket, and the linked production watcher. A temporary `ps` selector supplied **synthetic 1500-MiB RSS for that single scratch PID** so no live editor was probed. The resulting report recorded that PID, `lua_mem_mb=0.7`, buffer/extmark totals, and `lsp_clients=0`. Both scratch directories and the process were removed. The real launch agent was restarted; `launchctl print` showed it running with the new PATH. This proves collection works on a healthy core, **not** that the old high-RSS cause has been identified. The next real event should be examined using [the dumper's metrics](../scripts/nvim-leak-dump.lua#L14-L64).

The [persisted OOM investigation](file:///Users/pronvis/.claude/projects/-Users-pronvis-it-configs/memory/nvim-oom-watcher.md) already called the per-core cause unresolved and noted that an earlier `/tmp` watcher captured nothing. A **separate** [rust-analyzer startup race](lua/pronvis/rust_analyzer_join.lua#L1-L23) previously started four servers for one editor, about 1.2 GB; [the current attach gate](after/plugin/lsp.lua#L110-L119) addresses it. There is no dump linking that race to September's 8648-MiB core.

Scope: the historical readings come from the extant `report.log`; no rotated `.1` file was present at inspection. The isolated smoke used synthetic RSS, not a newly observed memory leak.
