#!/usr/bin/env node
// Merges (or removes) the harness permissions and hooks into ~/.claude/settings.json.
//
//   node merge-settings.js <settings.json> <settings.harness.json>           merge
//   node merge-settings.js <settings.json> <settings.harness.json> --remove  undo the merge
//
// Idempotent: entries are compared by value, so running it twice changes nothing.
// Anything else in the user's settings is left untouched.
const fs = require("fs");

const [settingsPath, harnessPath, flag] = process.argv.slice(2);
if (!settingsPath || !harnessPath) {
  console.error("usage: merge-settings.js <settings.json> <settings.harness.json> [--remove]");
  process.exit(1);
}
const remove = flag === "--remove";

const readJson = (p, fallback) => (fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : fallback);
const user = readJson(settingsPath, {});
const harness = readJson(harnessPath, null);
if (!harness) throw new Error(`cannot read ${harnessPath}`);

const key = (v) => JSON.stringify(v);
const union = (a = [], b = []) => [...a, ...b.filter((x) => !a.some((y) => key(y) === key(x)))];
const minus = (a = [], b = []) => a.filter((x) => !b.some((y) => key(y) === key(x)));
const apply = remove ? minus : union;

user.permissions = user.permissions || {};
for (const kind of ["allow", "ask", "deny"]) {
  user.permissions[kind] = apply(user.permissions[kind], harness.permissions?.[kind]);
  if (user.permissions[kind].length === 0) delete user.permissions[kind];
}
if (Object.keys(user.permissions).length === 0) delete user.permissions;

user.hooks = user.hooks || {};
for (const [event, entries] of Object.entries(harness.hooks || {})) {
  user.hooks[event] = apply(user.hooks[event], entries);
  if (user.hooks[event].length === 0) delete user.hooks[event];
}
if (Object.keys(user.hooks).length === 0) delete user.hooks;

fs.writeFileSync(settingsPath, JSON.stringify(user, null, 2) + "\n");
