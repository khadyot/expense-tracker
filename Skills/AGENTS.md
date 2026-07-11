# Expense Tracker — Agent Rules

This file governs how the execution agent (Gemini, in Antigravity) works in this
repository. These rules apply on top of, not instead of, the four skills in
`.agents/skills/`. Read the relevant skill before touching design, database,
privacy-sensitive, or native-bridge code, this file covers everything else.

## Project Identity

Expense Tracker is a local-first, privacy-preserving personal finance app built
in Flutter/Dart with a native Kotlin SMS ingestion bridge. All persistence is
local (Drift/SQLite). There is no backend, no cloud sync, no remote
authentication, and as of the voice parser migration, no external network calls
of any kind in the production app. Every decision defaults to preserving that
property.

## Architecture Standards

- **Layered structure**: `screens/` (UI, no business logic beyond widget state),
  `services/` (business logic, orchestration), `database/` (Drift tables, DAOs),
  `models/` (plain data classes), `widgets/` (reusable UI components),
  `theme/` (colors, text styles), `utils/` (pure functions, parsers, formatters),
  `constants/` (shared static data like category keyword tables)
- A screen file should not contain a Drift query directly, it calls a service or
  DAO method. A service file should not contain widget/UI code.
- State management is `Provider`, exclusively. Do not introduce `Bloc`, `Riverpod`,
  `GetX`, or any other state management package into this codebase, even for a
  single isolated feature. Consistency across the codebase matters more than any
  local convenience one alternative might offer.

## Import Hierarchy

Imports within a Dart file are grouped and ordered:

1. Dart SDK imports (`dart:async`, `dart:io`, etc.)
2. Flutter framework imports (`package:flutter/...`)
3. Third-party package imports (`package:provider/...`, `package:drift/...`)
4. Local project imports (`package:expense_tracker/...` or relative), themselves
   ordered: `models` before `services` before `database` before `widgets` before
   `screens`, since that roughly reflects the dependency direction

A `screens/` file may import from `services/`, `models/`, `widgets/`, `theme/`,
`constants/`. It should never be imported by any of those, dependencies flow one
direction, UI depends on logic, logic does not depend on UI.

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Private members: leading underscore, standard Dart convention
- Drift tables: PascalCase class name, Drift auto-generates the snake_case SQL
  table name, do not override this unless there is a documented reason
- Constants: `lowerCamelCase` for local/instance constants,
  `SCREAMING_SNAKE_CASE` only for genuinely global static constants like the
  MethodChannel name

## Formatting and Code Quality

- Run `dart format .` before considering any change complete
- Run `flutter analyze` and resolve any new warnings introduced by the change,
  pre-existing warnings unrelated to the current task do not need to be fixed
  opportunistically, stay scoped to the task
- No `print()` statements left in committed code, use a proper logging approach
  or remove debug output before finishing a task
- Avoid deeply nested widget trees inline, extract to named private widgets or
  separate files once a `build` method exceeds roughly 80-100 lines

## Testing Expectations

- New pure-logic files (parsers, matchers, utilities) get a corresponding test
  file in `test/`, mirroring the `lib/` path
- Database migrations are not considered complete without confirming
  `build_runner` ran clean, see `drift-db-management` skill
- UI changes do not require automated tests by default for this project's scope,
  but should be manually verified in both dark and light mode before being
  marked complete

## Scope Discipline

This project has an explicit, agreed 20% gap to close, tracked against a fixed
roadmap. Do not add features, packages, or architectural changes beyond what a
task explicitly asks for, even if they seem like natural improvements. If
something seems missing or worth adding while working on an assigned task, note
it at the end of your report rather than implementing it unprompted. Scope creep
here specifically means anything resembling: cloud sync, extra chart libraries,
multi-currency live FX, iOS SMS parsing, or new state management patterns,
these are explicitly excluded per the project audit.

## Reporting Back

Every non-trivial task (schema change, new service, new bridge behavior, new
skill-governed change) ends with a written report, not just a diff. The report
states: what was changed and why, files touched, any deviation from the
original instructions and the reason for it, and any open question or judgment
call that needs a human decision rather than being silently resolved. Assume the
report will be read by someone who was not watching the implementation happen
in real time.

## Tone in Reports and Comments

Write plainly. No filler enthusiasm, no "Great, I've successfully..." framing,
no unnecessary hedging. State what was done, state what wasn't, state why. Code
comments explain why a non-obvious decision was made, not what the code
obviously does line by line.
