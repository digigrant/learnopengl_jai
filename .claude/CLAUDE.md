# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file is a **router, not a container** — it holds no project prose itself. Every substantive
resource lives in its own file; this table says which ones to read, when, and whether you're
allowed to write back to them.

| Resource | Scope | Access | When to read |
|---|---|---|---|
| [`docs/architecture.md`](../docs/architecture.md) | project | read-write | **Mandatory, session start** — what this project is and how its modules fit together |
| [`docs/build-and-run.md`](../docs/build-and-run.md) | project | read-write | **Mandatory, session start** — how to compile, run, and test anything in this repo |
| [`README.md`](../README.md) (repo root) | project | read-write | **Mandatory, session start** — the owner's own project vision and current TODOs |
| `~/jai-notes/INDEX.md` | shared (outside this repo) | read-write repo (mostly read; append confirmed findings to the file it indexes them under) | **Mandatory before any question** about Jai language/stdlib/compiler-metaprogramming behavior. Load that index first and follow its own routing — do not duplicate its contents here |
| [`notes/test_programs/README.md`](../notes/test_programs/README.md) | project | read-only | Before modifying `modules/Status/RegisterStatus.jai`, or writing any similar cross-module compile-time code-registration pattern (`add_build_string` targeting another module's scope). Already index-shaped — open it and follow to the relevant repro rather than guessing |
| [`notes/register_status_handoff.md`](../notes/register_status_handoff.md) | project | read-only | Same trigger as above — narrative handoff on what was tried, what worked, and what didn't |
| [`notes/jai_compiler_field_notes.md`](../notes/jai_compiler_field_notes.md) | project | read-write (staging draft) | Same trigger as above. **Write newly confirmed Jai-compiler quirks here first** — this file is explicitly staged to graduate into `~/jai-notes/gotchas.md` / `field_notes.md`, not to replace them |

## Conventions

- **Mandatory** rows are read unconditionally at the start of a session, before doing any work.
- **Situational** rows are read only once their trigger condition applies — don't preload them.
- Rows marked "defer to index" point at a file that is itself a curated table of contents. Open
  and follow it; don't copy its contents back into this file — that creates a second copy that can
  drift out of sync with the original.
