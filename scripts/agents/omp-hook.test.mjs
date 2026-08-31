import assert from "node:assert/strict";

import ompTmuxStatus from "./omp-hook.mjs";

const handlers = new Map();
const calls = [];
let runtimeReady = false;

const api = {
	on(event, handler) {
		handlers.set(event, handler);
	},
	exec(command, args) {
		calls.push({ command, args });
		return runtimeReady
			? Promise.resolve()
			: Promise.reject(new Error("runtime actions unavailable during extension load"));
	},
};

ompTmuxStatus(api);
await Promise.resolve();

assert.equal(calls.length, 0, "the extension factory must not call runtime actions");

runtimeReady = true;
const sessionStart = handlers.get("session_start");
assert.equal(typeof sessionStart, "function", "session_start must report the initial state");

sessionStart();
await Promise.resolve();

assert.equal(calls.length, 1);
assert.equal(calls[0].command, "bash");
assert.equal(calls[0].args.at(-1), "idle");
