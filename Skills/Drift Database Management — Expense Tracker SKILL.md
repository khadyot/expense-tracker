---
name: drift-db-management
description: Use this skill whenever modifying database schemas, table definitions, queries, or running code generation for the Drift/SQLite layer in Expense Tracker. Trigger on any change to lib/database, any .dart file with @DataClassName or Table subclasses, or any request involving build_runner, migrations, or query changes.
---

# Drift Database Management — Expense Tracker

The Drift database (`AppDatabase`) is the single source of truth for all
persistent data. There is no backend, no cloud sync, no secondary database. Every
schema decision here is permanent for the life of a user's install, so treat
schema changes with more care than a typical CRUD table edit.

## Schema Change Workflow

Follow this exact order, do not skip steps or reorder them:

1. Edit the table definition (the `Table` subclass) in
   `lib/database/tables/*.dart`
2. Bump `schemaVersion` in `AppDatabase` (`lib/database/database.dart`) by exactly
   1, never skip a version number
3. Write a `MigrationStrategy` step in `onUpgrade` covering the exact version
   transition (`from == oldVersion && to == newVersion`), do not write a
   catch-all migration that silently handles multiple version jumps
4. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
5. Verify the generated `.g.dart` file compiles and the new/changed columns
   appear as expected before touching any UI code that depends on them

Never hand-edit a `.g.dart` generated file. If generation produces something
wrong, the fix belongs in the source table definition, not the generated output.

## Adding a New Table

- Table classes live in `lib/database/tables/`, one file per table
- Column naming: `snake_case` in SQL via Drift's default mapping, `camelCase` in
  the generated Dart accessors, do not override this mapping manually
- Every table gets an `id` auto-increment integer primary key unless there is a
  specific reason not to (state that reason in a code comment if so)
- Add the new table class to the `@DriftDatabase(tables: [...])` annotation list
  in `database.dart`
- Timestamps use `DateTimeColumn` stored as Unix epoch integers (Drift default),
  never store dates as formatted strings

## Modifying an Existing Table

- Never remove a column in the same change that also renames or repurposes it,
  these are two different migration operations even if they feel like one logical
  change
- Adding a nullable column or a column with a `.withDefault()` is a low-risk
  migration, prefer this over adding a required non-null column to an existing
  table with existing rows
- If a migration needs to backfill or transform existing data (not just add a
  column), write that transformation explicitly inside the `onUpgrade` step for
  that version, do not assume default values are sufficient

## Query Conventions

- Complex queries (date-range filtering, category totals, distinct merchants,
  duplicate detection) live in `lib/database/daos/` as methods on a DAO class, not
  inlined in screen or service files
- Use Drift's type-safe query builder (`select`, `where`, `orderBy`) over raw SQL
  wherever possible. Raw SQL via `customSelect` is acceptable only when the
  type-safe builder genuinely cannot express the query, document why in a comment
  when this happens
- Reactive queries (`.watch()`) power any UI that should update live, like the
  transaction list or the Safe-to-Spend gauge. One-shot queries (`.get()`) are for
  actions like CSV export or duplicate checks during insert, not for anything
  bound to a widget's `build` method

## build_runner Conflict Resolution

- If `build_runner build` reports conflicting outputs, use
  `--delete-conflicting-outputs`, this is safe for `.g.dart` files since they are
  fully regenerated, never manually resolve a generated-file conflict by editing
  the `.g.dart` output directly
- If generation fails with a type or annotation error, the fix is almost always
  in the table definition (missing `@DataClassName`, malformed column
  annotation, circular table reference), fix the source before rerunning
- After any schema change, run `flutter clean` if `build_runner` produces stale
  or inconsistent output that `--delete-conflicting-outputs` did not resolve

## Before Marking Any Schema Task Complete

- Confirm `schemaVersion` was incremented
- Confirm a corresponding `onUpgrade` migration step exists for that exact
  version transition
- Confirm `build_runner` ran clean with no errors
- Confirm no existing DAO query was silently broken by a column rename or type
  change, grep for the old column name across `lib/database/daos/` before
  considering the change done
