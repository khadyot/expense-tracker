---
name: native-bridge-sync
description: Use this skill whenever modifying the Android SMS ingestion pipeline, the MethodChannel bridge, SmsReceiver.kt, or any Dart file that sends or receives data across the platform channel. Trigger on any change touching android/app/src/main/kotlin or the corresponding Dart-side channel handler.
---

# Native Bridge Sync — Expense Tracker

The SMS ingestion pipeline crosses two languages: Kotlin does the interception
and regex parsing on the Android side, Dart receives structured results on the
Flutter side, via the `com.expensetracker/sms` `MethodChannel`. These two sides
have no compile-time contract between them, a mismatch only surfaces at runtime.
Treat every change to this bridge as a two-file change, never edit one side
without checking the other.

## The Contract

- Channel name: `com.expensetracker/sms`, defined as a constant in both
  `SmsReceiver.kt` (or `MainActivity.kt`, wherever the channel is registered) and
  the Dart-side handler. Never use a raw string literal for the channel name in
  more than one place per language, each language gets exactly one constant
  definition that everything else references.
- Method name for the SMS event: `onSmsTransaction`. If you add a new method to
  the channel, name it clearly and add it to both sides in the same change.
- Payload shape: whatever fields `onSmsTransaction` sends (amount, merchant,
  category, timestamp, raw SMS body) must match field-for-field on both sides.
  Kotlin sends a `Map<String, Any>` via `invokeMethod`, Dart receives it as
  `Map<dynamic, dynamic>` and must cast/parse every field explicitly, do not
  assume a field exists without a null check, a malformed SMS regex match on the
  Kotlin side can produce a partial payload.

## When Adding a New Bank SMS Regex Pattern

1. Add the pattern in `SmsReceiver.kt` alongside the existing patterns, keep the
   same structure (match, extract amount, extract merchant hint, convert date)
2. Confirm the payload sent via `invokeMethod("onSmsTransaction", ...)` still
   matches the exact field names the Dart side expects, adding a new bank pattern
   should never require changing the payload shape, if it does, that is a signal
   the new pattern does not fit the existing contract and needs discussion first
3. On the Dart side, confirm the category keyword mapping (shared with the voice
   parser via `lib/constants/category_keywords.dart`) covers any new merchant
   category this bank pattern introduces, do not let Kotlin introduce a category
   string that has no corresponding entry in the shared Dart keyword table

## When Changing the Payload Shape

This is the highest-risk change in this skill. If a field is added, renamed, or
removed from the `onSmsTransaction` payload:

- Update the Kotlin `invokeMethod` call
- Update the Dart-side parsing/casting logic in the same commit-equivalent
  change, never as a follow-up
- Update any Dart data class or model that represents the parsed SMS transaction
  (check `lib/models/` for a matching class)
- If the change is not backward compatible (a required field was renamed rather
  than added), note this explicitly, since a user's already-running app on an
  old build could theoretically send an old-shaped payload if hot-reload or a
  partial update ever leaves the two sides out of sync during development,
  this matters for dev-time debugging even though it is not a real production
  risk for a single-APK app

## Testing Bridge Changes

- Kotlin-side regex changes should be exercised with a manual test SMS (send a
  test message matching the new pattern to a test device or emulator with SIM
  simulation) before relying on the Dart side to catch a bad extraction
- Dart-side payload handling should have a unit test constructing a fake
  `Map<dynamic, dynamic>` payload (including a deliberately malformed one missing
  a field) to confirm the parsing logic does not crash on an unexpected shape

## Before Marking Any Bridge Task Complete

- Confirm the channel name and method name constants were not duplicated as
  fresh string literals anywhere
- Confirm the payload field names match exactly, case-sensitive, on both sides
- Confirm the Dart-side handler has a null/type check for every field, not a
  direct unchecked cast
- Confirm any new category introduced by a Kotlin-side pattern exists in the
  shared `category_keywords.dart` table
