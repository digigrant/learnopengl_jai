# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file is a **router, not a container** — it holds no project prose itself. Every substantive
resource lives in its own file; this table says which ones to read, when, and whether you're
allowed to write back to them.

| Resource | Scope | Access | When to read |
|---|---|---|---|
| [`docs/architecture.md`](../docs/architecture.md) | project | read-write | **Mandatory, session start** — what this project is and how its modules fit together |
| [`docs/build-and-run.md`](../docs/build-and-run.md) | project | read-write | **Mandatory, session start** — how to compile, run, and test anything in this repo |
| `~/jai-notes/INDEX.md` | shared (outside this repo) | read-write repo (mostly read; append confirmed findings to the file it indexes them under) | **Mandatory before any question** about Jai language/stdlib/compiler-metaprogramming behavior. Load that index first and follow its own routing — do not duplicate its contents here |

## Conventions

- **Mandatory** rows are read unconditionally at the start of a session, before doing any work.
- **Situational** rows are read only once their trigger condition applies — don't preload them.
- Rows marked "defer to index" point at a file that is itself a curated table of contents. Open
  and follow it; don't copy its contents back into this file — that creates a second copy that can
  drift out of sync with the original.
