# Voice Parser Migration — Implementation Report

**Date:** 2026-07-11  
**Project:** Expense Tracker (Local-First, Privacy-Preserving Personal Finance App)  
**Governing Skills Applied:** `privacy-first-guard`, `native-bridge-sync`, `design-aesthetics`, `drift-db-management`

---

## 1. Executive Summary & Rationale

We have successfully replaced the cloud-based Google Gemini voice parsing pipeline (`google_generative_ai`) with a 100% on-device, regex and rule-based heuristic voice parser (`LocalVoiceParser`). 

### Why This Migration Was Necessary
Previously, when users tapped the microphone button on the `AddExpenseScreen`, transcribed speech (`speech_to_text`) was sent across the network to Google's Gemini cloud API (`gemini-pro`) to extract JSON containing `amount`, `merchant`, and `category`. This broke the core architectural premise of Expense Tracker: **"All persistence is local. There is no backend, no cloud sync, no remote authentication, and no external network calls of any kind in the production app."**

Furthermore, the cloud implementation had:
1. A hardcoded API key (`AIzaSy...`) exposed directly in the `AddExpenseScreen` source code.
2. A broken/unstable model reference (`gemini-pro`).
3. External network latency and failure modes incompatible with offline usage.

By implementing `LocalVoiceParser`, `NumberWordParser`, and `MerchantMatcher` natively in Dart using `string_similarity`, all three data ingestion paths—**SMS (`SmsService`), Voice (`VoiceService`), and Manual Entry (`AddExpenseScreen`)**—are now strictly local, zero-network, and privacy-first.

---

## 2. Files Touched & Created

### Modified Files
1. `pubspec.yaml`
   - **Removed dependency:** `google_generative_ai: ^0.4.7`
   - **Removed dependency:** `http: ^1.6.0` (no longer required by voice service)
   - **Added dependency:** `string_similarity: ^2.2.0` (for local Dice's coefficient merchant fuzzy matching)
2. `lib/services/sms_service.dart`
   - Updated `_categorizeTransaction()` to delegate directly to `CategoryKeywords.categorize()` rather than maintaining ad-hoc category arrays, ensuring unified categorization behavior across SMS and voice.
3. `lib/services/voice_service.dart`
   - Completely removed `GenerativeModel` client and cloud JSON parsing logic.
   - Refactored `startListening()` to invoke `LocalVoiceParser.parse()` once speech recognition completes, query `database.getAllMerchants()` for known merchant targets, and return `VoiceParseResult` via the `onResultParsed` callback.
4. `lib/screens/add_expense_screen.dart`
   - **Security:** Removed hardcoded `AIzaSy...` API key string completely (line 79 replaced with zero-arg `VoiceService(widget.database)` initialization).
   - **UI/UX:** Added `_onVoiceResultParsed(VoiceParseResult result)` handler.
   - **Confidence Routing:** If `result.isHighConfidence` (`score >= 2.0`), pops up a glassmorphism-inspired **One-Tap Save Confirmation Dialog**. If `result.confidenceScore < 2.0`, auto-fills best guesses and displays subtle warning borders (`AppColors.warningBorder`) and warning badges on any uncertain field (`_isAmountUncertain`, `_isMerchantUncertain`, `_isCategoryUncertain`) requiring manual review.

### Created Files
5. `lib/constants/category_keywords.dart`
   - **Shared Source of Truth:** Centralized keyword dictionary (`Groceries`, `Travel`, `Car`, `Home`, `Rent`, `Salary`, `Investment Returns`, `Other Income`). Coordinates cleanly across Dart services (`LocalVoiceParser`, `SmsService`) per `native-bridge-sync` standards.
6. `lib/utils/number_word_parser.dart`
   - Converts both numeric digits (`"150"`, `"1,200"`) and spoken English/Indian-English compound words (`"two fifty" -> 250`, `"twelve fifty" -> 1250`, `"three twenty five" -> 325`, `"four thousand" -> 4000`) into exact double values.
7. `lib/utils/merchant_matcher.dart`
   - Evaluates spoken merchant text against `knownMerchants` using `string_similarity.similarityTo()`. If similarity meets or exceeds `threshold = 0.7` (e.g. `"Starbuck"` -> `"Starbucks"`, `"dmart"` -> `"D-Mart"`), it snaps to the exact database merchant spelling and sets `isMatched = true`.
8. `lib/services/local_voice_parser.dart`
   - Core orchestrator executing priority regex phrase templates (`<amount> for <merchant>`, `<merchant> for <amount>`, `spent <amount> at <merchant>`, `<amount> at <merchant>`, and `<merchant> <amount> rupees`).
   - Calculates a 3-component confidence score (`0.0` to `2.5`) and flags specific field cleanliness.
9. `lib/theme/app_colors.dart`
   - Implemented HSL-tailored color tokens (`AppColors.warningBorder`, `warningSurfaceDark`, `warningSurfaceLight`, `successSurface`) for visual flagging per `design-aesthetics` rules without raw inline hex literals.
10. `test/local_voice_parser_test.dart`
    - Comprehensive test suite covering **18 distinct STT transcripts**, including compound number words, fuzzy merchant matching, inferred categories, and 4 explicit below-threshold awkward/incomplete transcripts (`confidenceScore < 2.0`). **All 18 tests pass cleanly (`flutter test`).**

---

## 3. Architecture & Confidence Scoring Mechanics

### Priority Phrase Templates (`LocalVoiceParser`)
When clean text (`strip timestamps/fillers/currency tokens`) enters `LocalVoiceParser.parse()`, it checks 5 templates in strict priority order:
1. `r'^(.+?)\s+for\s+(.+)$'` (with numeric first group) $\rightarrow$ e.g., *"150 for Starbucks"*, *"two fifty for groceries"*
2. `r'^(.+?)\s+for\s+(.+)$'` (with numeric second group) $\rightarrow$ e.g., *"Starbucks for 150 rupees"*, *"Uber for two hundred"*
3. `r'^(?:spent|paid)\s+(.+?)\s+(?:at|on|to)\s+(.+)$'` $\rightarrow$ e.g., *"spent 450 at D-Mart"*, *"paid 1500 to Shell petrol pump"*
4. `r'^(.+?)\s+(?:at|on|to)\s+(.+)$'` $\rightarrow$ e.g., *"500 at Shell petrol pump"*, *"eighty at Starbuck"*
5. `r'^(.+?)\s+([0-9.,]+|\w+(?:\s+\w+){0,3})\s*(?:rupees|rs|inr|₹|bucks)?$'` $\rightarrow$ e.g., *"Uber 250 rupees"*, *"BigBasket 1200"*
*Fallback:* If no template matches cleanly, extracts any valid number via `NumberWordParser` (`amount`) and removes numeric tokens from the string to form the `merchant` candidate.

### Confidence Scoring Breakdown (Max: 2.5)
- **Amount Clean (`+1.0`):** `amount != null && amount > 0`
- **Merchant Match (`+1.0` vs `+0.5`):**
  - `+1.0` if `string_similarity >= 0.7` with a known database merchant (`isMerchantMatched = true`).
  - `+0.5` if merchant string is non-empty but unmatched (`isMerchantMatched = false`).
- **Category Inferred (`+0.5` vs `+0.0`):**
  - `+0.5` if `CategoryKeywords.categorize()` returns a specific category (`Groceries`, `Travel`, etc.).
  - `+0.0` if it falls back to `'Other'` (`or 'Other Income'`).

### Threshold & UI Routing
- **Threshold (`2.0`):**
  - **Score $\ge 2.0$ (`isHighConfidence = true`):** Form fields auto-fill cleanly, and a **One-Tap Save** confirmation modal appears allowing instant persistence with zero manual typing.
  - **Score $< 2.0$ (`isHighConfidence = false`):** Form fields pre-fill with best guesses, but any field that scored low (`!isAmountClean`, `!isMerchantMatched`, `!isCategoryInferred`) is visually highlighted with warning borders (`AppColors.warningBorder`), subtle surface tinting, and an inline warning badge urging user review. When the user modifies that field, the warning state automatically clears.

---

## 4. `native-bridge-sync` Category Keyword Coordination

Per the `native-bridge-sync` skill guidelines, we evaluated whether to duplicate `CategoryKeywords` into Kotlin (`android/app/src/main/kotlin/.../SmsReceiver.kt`) or maintain Dart as the single source of truth (`lib/constants/category_keywords.dart`).

**Architectural Decision:** We established **Dart as the single source of truth** (`CategoryKeywords.categorize()`).
- In our Android SMS pipeline, `SmsReceiver.kt` acts strictly as a lightweight native bridge (`SmsReceiver.kt` receives broadcast -> checks bank sender -> extracts raw amount/merchant -> pushes raw data across `MethodChannel` `"com.expensetracker/sms"`).
- `SmsService.dart` receives this raw map on the Dart side and immediately invokes `CategoryKeywords.categorize(merchant + body)`.
- By using `lib/constants/category_keywords.dart` across both `SmsService.dart` and `LocalVoiceParser.dart`, we eliminate split-brain category drift without adding JNI overhead or duplicate keyword maintenance across languages.

---

## 5. Verification & Privacy Audit Results

### Unit Test Verification (`test/local_voice_parser_test.dart`)
Ran `/Users/khadyot/flutter/bin/flutter test test/local_voice_parser_test.dart`:
```
00:00 +18: All tests passed!
```
All 18 test cases across high-confidence templates, compound Indian numerals, fuzzy matching, and below-threshold error scenarios verified successfully.

### Static Analysis (`flutter analyze`)
Ran `/Users/khadyot/flutter/bin/flutter analyze`:
```
61 issues found. (ran in 13.1s)
```
All 61 issues found are purely informational deprecation notices (`withOpacity` $\rightarrow$ `withValues`) in pre-existing files (`transaction_items.dart`, `notification_settings_screen.dart`, etc.). **Zero errors, zero warnings, and zero new issues were introduced by our voice parser migration.**

### Hard Constraint Privacy Audit (`privacy-first-guard`)
Before marking this task complete, we conducted a rigorous `grep_search` audit across all `lib/` and `test/` files:
1. **Network SDKs:** ZERO occurrences of `google_generative_ai`, `package:http`, or `package:dio`.
2. **Telemetry / Crash Reporting:** ZERO occurrences of `firebase`, `sentry`, or `posthog`.
3. **Hardcoded API Keys / Credentials:** ZERO occurrences of `AIzaSy...` or bearer tokens.
4. **Data Sinks:** All voice transcripts and parsed entities remain exclusively inside short-lived widget/service memory before being inserted directly into local SQLite/Drift (`AppDatabase`).

**Final Confirmation Statement:**  
`Privacy Guard check passed: zero cloud/network dependencies in modified files.`

---

## 6. Deviations & Open Questions

- **Deviations from Instructions:** None. All required files were created exactly as specified with 3-tier confidence scoring (`+1`, `+1/+0.5`, `+0.5`), 5 priority templates, Indian compound number word parsing, fuzzy merchant matching, and zero cloud calls.
- **Open Questions / Judgment Calls:** None. The voice pipeline is now completely offline, responsive, and portfolio-ready.
