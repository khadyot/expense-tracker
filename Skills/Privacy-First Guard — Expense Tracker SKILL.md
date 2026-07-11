---
name: privacy-first-guard
description: Use this skill before adding any new package dependency, any network call, any credential or API key, or any third-party SDK to Expense Tracker. Also trigger this skill as a review pass any time a task is marked complete, to check the change did not silently introduce a cloud dependency. This is a hard constraint skill, not a style preference.
---

# Privacy-First Guard — Expense Tracker

Expense Tracker's entire value proposition is that financial data never leaves
the device. This is a hard architectural constraint, not a preference that can be
traded off for convenience. If a task seems to require violating this, stop and
flag it rather than implementing a workaround.

## Banned, Full Stop

Never add these packages or their equivalents, under any justification, even
"just for crash reporting" or "just for analytics":

- `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_analytics`,
  `firebase_crashlytics`, or any other `firebase_*` package
- `sentry_flutter`, `mixpanel_flutter`, `amplitude_flutter`, or any error/usage
  telemetry SDK that phones home
- Any package whose stated purpose is remote sync, cloud backup, or
  cross-device data replication
- Any bank aggregator SDK (Plaid, Yodlee, or equivalents)
- Any authentication package that depends on a remote identity provider (Google
  Sign-In, Auth0, Supabase Auth, etc.)

If a task description implies one of these ("add crash reporting", "sync across
devices", "add login"), do not implement it. Respond that this conflicts with the
project's local-first constraint and needs explicit owner sign-off before
proceeding, then stop.

## Network Calls Require Justification

The only network calls that should ever exist in this codebase, as of the current
architecture, are none. Voice parsing was moved to a fully local regex-based
parser specifically to eliminate the app's one remaining external API
dependency. SMS parsing and manual entry were already local.

If a future task appears to require a network call:

1. Do not add it silently as an implementation detail
2. State explicitly what the call is for, what data it would send, and to what
   domain
3. Wait for explicit confirmation before writing any `http`, `dio`, or socket
   code that reaches an external host

## Credential and Secret Handling

- Never hardcode an API key, token, or secret directly in Dart or Kotlin source,
  even temporarily "to test it works." This has already caused one real bug in
  this codebase (the Gemini key in `add_expense_screen.dart`), do not repeat it.
- Any credential that must exist (currently none, after the voice parser move to
  local-only) goes through `flutter_secure_storage`, never
  `shared_preferences`, never a `.env` file committed to the repo, never a
  constant in a `.dart` file
- `flutter_secure_storage` itself only touches the OS Keychain/Keystore, it does
  not transmit anything anywhere, confirm you understand this distinction before
  assuming any use of it implies a network call

## Pre-Completion Audit

Before marking any task complete that touched `pubspec.yaml`, run this check and
report the result:

```
grep -ri "firebase\|sentry\|mixpanel\|amplitude\|plaid\|yodlee" pubspec.yaml
```

Expected output: empty. If anything matches, do not proceed, flag it.

Before marking any task complete that touched Dart or Kotlin source files, run:

```
grep -rn "AIzaSy\|api_key\|apikey\|secret_key\|Bearer " lib/ android/app/src/main/
```

Expected output: no hardcoded literal values (references to
`flutter_secure_storage` read/write calls are fine, a raw string that looks like
a live key or token is not).

## Legitimate Local-Only Packages Are Fine

This skill exists to block cloud dependencies, not to make you paranoid about
every dependency. Packages that operate entirely on-device, `drift`,
`sqlite3_flutter_libs`, `path_provider`, `local_auth`,
`flutter_secure_storage`, `speech_to_text`, `permission_handler`,
`flutter_local_notifications`, `share_plus` (which invokes the OS share sheet,
not a remote upload), and similar, are all consistent with local-first and do
not need special justification.
