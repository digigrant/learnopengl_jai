#!/usr/bin/env bash
# SessionStart hook: force-loads the files .claude/CLAUDE.md's router table marks
# "Mandatory, session start" into context, so an agent can't skip them the way a
# prior session did (committed straight to jai-notes' main branch, missing
# git-workflow.md's "never work directly on main" rule).
set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# claude-shared/ is looked up under a few candidate home directories, not just $HOME:
# in this sandbox the hook-executing user's $HOME (/home/agent) differs from the
# account whose files are actually being worked on (/home/grant) -- same split
# documented in this repo's own CLAUDE.md ("Environment" section). Checking a short
# candidate list keeps this working here without hardcoding a path that would be
# wrong on a normal (non-sandboxed) machine where $HOME is correct.
shared_dir=""
for candidate in "$HOME/claude-shared" "/home/grant/claude-shared" "$(dirname "$HOME")"/*/claude-shared; do
  if [[ -d "$candidate" ]]; then
    shared_dir="$candidate"
    break
  fi
done

files=(
  "$project_dir/docs/architecture.md"
  "$project_dir/docs/build-and-run.md"
  "${shared_dir:-$HOME/claude-shared}/git-workflow.md"
  "${shared_dir:-$HOME/claude-shared}/task-execution.md"
)

content=""
missing=()
for f in "${files[@]}"; do
  if [[ -f "$f" ]]; then
    content+=$'\n\n=== '"$f"$' ===\n'
    content+="$(cat "$f")"
  else
    missing+=("$f")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  content+=$'\n\nWARNING: the following mandatory files were not found and could NOT be loaded: '"${missing[*]}"
fi

preamble="MANDATORY SESSION-START READING (per .claude/CLAUDE.md's router table). These files are loaded automatically -- do not skip, defer, or re-derive them from memory, and do not start task work before treating their rules as active for the rest of this session (in particular git-workflow.md's branch/commit rules)."

jq -n --arg text "$preamble$content" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $text
  },
  systemMessage: "Loaded mandatory session-start docs: architecture.md, build-and-run.md, git-workflow.md, task-execution.md."
}'
