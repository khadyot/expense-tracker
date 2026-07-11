# Expense Tracker — Codebase Audit Report & Portfolio Demo Roadmap

## 1. Architectural Snapshot

### What This Project Does & Problem Solved
**Expense Tracker** is a **Local-First, Privacy-Preserving AI Financial Assistant**. Traditional financial tracking apps either require high-friction manual data entry or force users to hand over sensitive bank login credentials to cloud aggregators (e.g., Plaid/Mint). 

This project solves both problems by using two frictionless, zero-cloud-account ingestion vectors right on the user's device:
1. **Native SMS Auto-Parsing**: Intercepts and parses bank transaction SMS alerts locally on Android via regular expressions without transmitting personal messages or financial data to third-party servers.
2. **AI Voice Ingestion**: Uses natural language speech-to-text combined with Google's Gemini LLM to let users speak entries naturally (*"Coffee for 150 rupees at Starbucks"*) and automatically extract structured JSON (Item, Amount, Category).

It pairs these data pipelines with a **Safe-to-Spend Speedometer** (a dynamic daily gauge factoring in monthly limits) and **Ghost Bills** (algorithmically predicted upcoming recurring subscriptions and bills).

### Core Stack & Key Infrastructure
* **Core Framework & Language**: **Flutter / Dart** (`>=3.0.0 <4.0.0`), with **Kotlin** (`SmsReceiver.kt`, `MainActivity.kt`) for native Android platform channels (`com.expensetracker/sms`).
* **Local Persistence Layer**: **Drift (`^2.22.0`)** over **SQLite** (`sqlite3_flutter_libs`), using reactive queries for transactions and ghost bill predictions (`database.dart` / `database.g.dart`).
* **State Management & UI**: **Provider (`^6.1.0`)** for reactive user preferences (`UserProvider`), custom glassmorphism containers (`AppTheme`), and custom canvas rendering (`SpeedometerPainter`).
* **AI & Voice Engine**: **`google_generative_ai` (`^0.4.6`)** querying the Gemini API via zero-shot JSON prompting, paired with **`speech_to_text` (`^7.0.0`)** for local speech recognition.
* **Security & Device Utilities**: **`local_auth` (`^2.3.0`)** + **`flutter_secure_storage` (`^9.2.2`)** for biometric and SHA-256 PIN/Password app locking (`AppLockWrapper`), **`permission_handler` (`^11.3.1`)** for SMS and microphone access, **`flutter_local_notifications` (`^18.0.0`)** + **`timezone`** for scheduled daily reminders and budget alerts, and **`csv` + `share_plus`** for local data exports.

---

## 2. State of the Build

### Completed Functional Modules
1. **Drift SQLite Database Layer (`AppDatabase`)**: Fully constructed with tables for `Transactions` and `GhostBills`. Includes queries for date-range filtering, category sums, distinct merchants, active day counts, and a daily duplicate detection engine (`findDuplicate`).
2. **Android Native SMS Interception Pipeline (`SmsReceiver.kt`, `MainActivity.kt`, `SmsService`)**: Fully functional `BroadcastReceiver` that captures incoming SMS, matches against 3 common Indian banking regex patterns (Rs/INR debited/spent), parses dates, and bridges over a `MethodChannel` (`onSmsTransaction`) directly to DB insertion with automatic merchant categorization (*Groceries, Travel, Car, Home*).
3. **Voice Ingestion & AI Extraction (`VoiceService`, `AddExpenseScreen`)**: Fully wired speech recognition that captures spoken audio and sends the transcript to Gemini with strict JSON formatting instructions. Automatically capitalizes merchants and checks for duplicate entries for the current day.
4. **Dashboard & Safe-to-Spend Gauge (`HomeScreen`, `SpeedometerWidget`)**: Custom dual-layer circular gauge that calculates remaining safe daily budget (`dailyLimit - currentSpent`) alongside predicted upcoming ghost bills (`predictedSpend`). Features animated progress bars and transaction list animations.
5. **Security Suite (`AppLockWrapper`, `PrivacySecurityScreen`, `SecuritySetupScreen`)**: Production-grade lifecycle-aware wrapper (`AppLifecycleState.resumed`) enforcing Biometrics, PIN, or Password authentication on app resume, plus a toggleable **Privacy Mode** (`₹****`) that hides sensitive figures across the UI.
6. **Data Management & Export (`PrivacySecurityScreen`, `HistoryScreen`)**: Grouped chronological transaction history (*Today, Yesterday, Date*) with tap-to-edit support, plus CSV data generation and native OS sharing.

### Data Flow Pipeline Map
```
[Ingestion Vectors]
 1. [Bank SMS received on Android] ──> SmsReceiver.kt (Regex Match & Date Parse) ──> MethodChannel ("onSmsTransaction") ──┐
 2. [Microphone Voice Input] ──> SpeechToText ──> VoiceService (Prompt Gemini API) ──> Structured JSON Response ────────┼──> [Reconciliation Engine (`findDuplicate`)]
 3. [Manual UI Entry / Edit] ──> AddExpenseScreen (`_amountController`, `_merchantController`) ────────────────────────────┘              │
                                                                                                                                      ▼
[Output & Presentation]                                                                                                        [Drift SQLite DB (`Transactions` table)]
  [HomeScreen Dashboard] <── (Reactive / Future queries via `_loadData()`) <──────────────────────────────────────────────────────────┴─┬────────────────────────────────┐
       ├─> Speedometer Gauge (Current Spent vs Daily Limit + Safe-to-Spend)                                                               │                                │
       ├─> Ghost Bills Section (`_upcomingBills`)                                                                                         ▼                                ▼
       └─> Today's Activity List & History Screen (`TransactionListItem`)                                                  [Analytics Engine]             [CSV Export (`share_plus`)]
```

---

## 3. The 20% Gap Analysis

### 🚨 Critical Blockers (Must Fix for Showcase State)
1. **Invalid Gemini API Model Name & Hardcoded Key (`voice_service.dart:17`, `add_expense_screen.dart:79`)**:
   - `VoiceService` currently specifies `model: 'gemini-2.5-flash-lite' // Trying 2.5 Flash as 2.0 Flash is missing`. `gemini-2.5-flash-lite` is not a valid public model identifier, which will cause API 404/invalid model errors during voice extraction. Must be updated to a reliable model like `gemini-1.5-flash` or `gemini-2.0-flash`.
   - `AddExpenseScreen` hardcodes an API key directly inside source code rather than allowing the user/evaluator to input or configure their own API key via the app UI, making the demo fragile or requiring code edits to test voice input.
2. **Missing Ghost Bills Inference & Seeding Engine (`database.dart`, `HomeScreen`)**:
   - The UI and database schema for `GhostBills` are fully built, but **no logic exists to generate or predict them**. Without an algorithm or smart seeding utility generating recurring bills, the "Upcoming Bills" section on the dashboard is completely blank on a clean run, rendering a major portfolio feature invisible.
3. **Stubbed "See All" UI Glue on Dashboard (`home_screen.dart:437`)**:
   - The "See All" button next to **Upcoming Bills** (`TextButton(onPressed: () {}, child: const Text('See All'))` at line 437) has an empty callback (`() {}`). Clicking it does nothing.
4. **Missing First-Launch Permission & Onboarding Checks (`main.dart`, `HomeScreen`)**:
   - While `SmsService` and `NotificationService` have permission request methods, the app never proactively prompts or checks for SMS/Notification permissions on startup, leaving the SMS interception engine inactive unless the user manually grants permissions via Android OS settings.
5. **Inconsistent Error & Currency Formatting (`voice_service.dart:151`)**:
   - `_saveVoiceTransaction` throws an exception using the dollar sign (`\$$amount`), while the app strictly enforces Indian Rupees (`₹`) everywhere else (`UserProvider.currency`).

### 💡 Nice-to-Haves (Excluded to Prevent Scope Creep)
* **Cloud Authentication & Sync (`profile_screen.dart:167`)**: The "Log Out" button currently triggers a snackbar saying *"Logout functionality coming soon!"*. Since the project's core philosophy is strict **Local-First Privacy**, building cloud user auth is scope creep and unnecessary. We should instead convert or clarify this action as a local data/profile reset.
* **Live Foreign Exchange API**: Multi-currency conversion via live exchange rates.
* **iOS SMS Auto-Parsing**: Apple blocks third-party SMS reading by design; building alternative OCR/receipt scanning is out of scope.
* **Complex Graphical Charts**: Adding extra chart libraries (`fl_chart` bar/pie charts) when the current grouped history list and circular speedometer already provide clean visual analysis.

---

## 4. Portfolio Demo Roadmap

Below is the exact, prioritized sequential checklist required to bring the project to a flawless showcase state without scope creep.

### Step 1: AI Configuration & Model Stabilization
* [ ] Fix the model identifier in `lib/services/voice_service.dart` from the invalid `gemini-2.5-flash-lite` to `gemini-1.5-flash` (or `gemini-2.0-flash`).
* [ ] Add a clean **AI Settings & API Key Manager** section inside `ProfileScreen` / `EditProfileScreen` (stored securely via `FlutterSecureStorage` or `SharedPreferences`), allowing evaluators to paste their Gemini API key directly inside the UI without touching source code.

### Step 2: Ghost Bills Prediction & Seeding Engine
* [ ] Implement a lightweight `GhostBillService` (or method inside `AppDatabase`) that analyzes recurring transactions (`isRecurring == true` or frequent merchants) to automatically insert/update `GhostBills`.
* [ ] Create a smart **Demo Seed Utility** (triggered on first launch or via a "Load Demo Data" button in Settings) that seeds realistic sample transactions and active `GhostBills` (*Netflix, Spotify, Gym Membership, Broadband*), ensuring evaluators immediately experience the **Safe-to-Spend Speedometer** and Ghost Bills in action.

### Step 3: UI Glue & Flow Polish
* [ ] Connect the empty `onPressed: () {}` callback on `HomeScreen` (*"See All" Upcoming Bills*, line 437) to a dedicated modal bottom sheet or screen listing all predicted Ghost Bills with options to view details or mark as paid.
* [ ] Refine the "Log Out" button on `ProfileScreen` to either reset the local profile/lock state or serve as a clean **"Reset & Reload Demo Data"** action suited for a portfolio demo.
* [ ] Standardize currency symbol formatting (`₹`) across all error messages and snackbars.

### Step 4: Permission & Onboarding Polish
* [ ] Add a clean, non-intrusive initialization check on `HomeScreen` startup that verifies and prompts for `Permission.sms` (on Android) and `NotificationService()._requestPermissions()`, ensuring SMS auto-parsing and daily reminders work immediately after launch.

### Step 5: Professional Documentation Polish (`README.md`)
* [ ] Update `README.md` to showcase the completed architecture, exact local setup instructions, UI key configuration steps, and high-level feature highlights with zero broken references.
