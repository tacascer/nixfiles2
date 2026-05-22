import test from "node:test";
import assert from "node:assert/strict";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const { createJiti } = require("jiti");
const jiti = createJiti(import.meta.url);

const {
	latestRecordedState,
	isLinkedWorktree,
	shouldPromptForPreservation,
} = jiti("./git-worktree-session.ts");

test("latestRecordedState reads the newest worktree state on the active branch", () => {
	const stale = {
		worktreePath: "/repo/.worktrees/stale",
		mainWorktreePath: "/repo",
		recordedAt: "2026-01-01T00:00:00.000Z",
	};
	const active = {
		worktreePath: "/repo/.worktrees/active",
		mainWorktreePath: "/repo",
		branch: "fix",
		recordedAt: "2026-01-02T00:00:00.000Z",
	};

	const state = latestRecordedState({
		sessionManager: {
			getEntries: () => [],
			getBranch: () => [
				{ type: "custom", customType: "git-worktree-session", data: stale },
				{ type: "message", message: { role: "user", content: "hello" } },
				{ type: "custom", customType: "git-worktree-session", data: active },
			],
		},
	});

	assert.deepEqual(state, active);
});

test("latestRecordedState ignores abandoned branch entries", () => {
	const active = {
		worktreePath: "/repo/.worktrees/active",
		mainWorktreePath: "/repo",
		recordedAt: "2026-01-01T00:00:00.000Z",
	};
	const abandoned = {
		worktreePath: "/repo/.worktrees/abandoned",
		mainWorktreePath: "/repo",
		recordedAt: "2026-01-02T00:00:00.000Z",
	};

	const state = latestRecordedState({
		sessionManager: {
			getEntries: () => [
				{ type: "custom", customType: "git-worktree-session", data: active },
				{ type: "custom", customType: "git-worktree-session", data: abandoned },
			],
			getBranch: () => [
				{ type: "custom", customType: "git-worktree-session", data: active },
			],
		},
	});

	assert.deepEqual(state, active);
});

test("latestRecordedState falls back to getEntries for older session manager mocks", () => {
	const state = {
		worktreePath: "/repo/.worktrees/fallback",
		mainWorktreePath: "/repo",
		recordedAt: "2026-01-01T00:00:00.000Z",
	};

	assert.deepEqual(
		latestRecordedState({
			sessionManager: {
				getEntries: () => [
					{ type: "custom", customType: "git-worktree-session", data: state },
				],
			},
		}),
		state,
	);
});

test("worktree helpers classify prompt and linked-worktree state", () => {
	assert.equal(shouldPromptForPreservation("quit"), true);
	assert.equal(shouldPromptForPreservation("new"), true);
	assert.equal(shouldPromptForPreservation("resume"), false);
	assert.equal(shouldPromptForPreservation("fork"), false);
	assert.equal(shouldPromptForPreservation("reload"), false);

	assert.equal(
		isLinkedWorktree({ worktreePath: "/repo/.worktrees/fix", mainWorktreePath: "/repo", recordedAt: "now" }),
		true,
	);
	assert.equal(
		isLinkedWorktree({ worktreePath: "/repo", mainWorktreePath: "/repo", recordedAt: "now" }),
		false,
	);
});
