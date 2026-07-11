# Expense Tracker — Local-First, Privacy-Preserving Personal Finance

<p align="center">
  <b>A state-of-the-art Flutter & Kotlin personal finance application designed from the ground up for absolute data privacy, local-first execution, and instant on-device intelligence.</b>
</p>

---

## 1. What This Project Does

**Expense Tracker** eliminates the friction of manual financial tracking while guaranteeing that **your financial data never leaves your device**. Unlike conventional finance apps that upload sensitive bank SMS, audio recordings, or transaction logs to third-party cloud servers, Expense Tracker performs every parsing, prediction, and storage operation **100% locally on your phone**.

### Core Highlights
- **Local Bank SMS Auto-Parsing**: Intercepts and parses transaction SMS directly via native Android `BroadcastReceiver` and regular expressions.
- **On-Device Voice Entry**: Records speech and parses natural language expense commands (e.g., *"twelve fifty for Swiggy"*) using an on-device regex and heuristic parsing engine (`LocalVoiceParser`).
- **Algorithmic Ghost Bills Prediction**: Automatically detects recurring subscriptions and utility bills from your transaction history without external AI models.
- **Safe-to-Spend Speedometer**: A dynamic, interactive gauge tracking today's spending against your daily budget and upcoming bill deductions.
- **Zero Configuration & Zero Accounts**: No login screens, no cloud sign-ups, and no API keys required. Works instantly out of the box.

---

## 2. Architecture Overview

### The Zero-Network Guarantee
Expense Tracker is built under a strict privacy constraint (`privacy-first-guard`): **this app makes zero network requests across all code paths**. 

There are no HTTP clients (`http`, `dio`), no WebSocket connections, no analytics trackers (`Firebase`, `Mixpanel`), and no cloud AI APIs (`Gemini`, `OpenAI`). All persistence uses `Drift` (SQLite) with encrypted OS Keychain/Keystore credential storage (`flutter_secure_storage`).

```
+-----------------------------------------------------------------------------------+
|                               FLUTTER & KOTLIN APP                                |
|                                                                                   |
|  +---------------------+   +-----------------------+   +-----------------------+  |
|  |     SMS Ingestion   |   |     Voice Ingestion   |   |     Manual Entry      |  |
|  | (Kotlin Broadcast   |   |  (Speech-to-Text SDK  |   |  (Interactive UI &    |  |
|  |  Receiver + Regex)  |   |   + Local Regex Engine) |   |   Category Picker)    |  |
|  +----------+----------+   +-----------+-----------+   +-----------+-----------+  |
|             |                          |                           |              |
|             +--------------------------+---------------------------+              |
|                                        |                                          |
|                                        v                                          |
|                         +------------------------------+                          |
|                         |  Drift SQLite Local Database |                          |
|                         |  (Transactions & GhostBills) |                          |
|                         +--------------+---------------+                          |
|                                        |                                          |
|             +--------------------------+---------------------------+              |
|             |                          |                           |              |
|             v                          v                           v              |
|  +---------------------+   +-----------------------+   +-----------------------+  |
|  |    Safe-to-Spend    |   |  Algorithmic Ghost    |   |   Biometric Security  |  |
|  |   Speedometer UI    |   |  Bill Recurrence      |   |   & CSV Export        |  |
|  +---------------------+   +-----------------------+   +-----------------------+  |
+-----------------------------------------------------------------------------------+
|               ZERO EXTERNAL NETWORK CALLS • ZERO CLOUD DEPENDENCIES               |
+-----------------------------------------------------------------------------------+
```

### Technology Stack Table

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Core Framework** | Flutter / Dart (`>=3.0.0`) | Cross-platform UI, animation engine, and business logic |
| **Native Android Bridge** | Kotlin (`SmsReceiver.kt`) | Background SMS interception and MethodChannel communication |
| **Local Database** | Drift / SQLite (`^2.22.0`) | Type-safe, reactive local persistence (`0` cloud sync) |
| **Voice Recognition** | `speech_to_text` (`^7.0.0`) | On-device speech recognition to raw transcript |
| **Local Voice Parser** | Custom Dart Engine + `string_similarity` | Heuristic phrase matching, number-word conversion, and fuzzy merchant matching |
| **State Management** | `provider` (`^6.1.0`) | Predictable, reactive widget state orchestration |
| **Security & Storage** | `local_auth` + `flutter_secure_storage` | OS-level biometric authentication and encrypted PIN storage |
| **Visual Charts** | `fl_chart` (`^0.69.0`) | Included in `pubspec.yaml` as a dormant dependency (unused in `lib/`); charts & gauges use native `CustomPainter` |
| **Permissions** | `permission_handler` (`^11.3.1`) | Sequential, context-aware OS permission requests |

---

## 3. Core Features

### 1. Safe-to-Spend Speedometer
A vibrant, glassmorphism-enhanced gauge positioned at the top of your dashboard. It dynamically calculates your remaining safe daily allowance by evaluating your total monthly budget, actual spend today, active days remaining, and upcoming algorithmic `Ghost Bills`.

### 2. Algorithmic Ghost Bills (`See All` Bottom Sheet)
Instead of relying on hardcoded entries or cloud LLM calls, our on-device `GhostBillService` continuously scans your transaction history. It detects recurring cadence (`25–35 days`), date tolerances (`<= 5 days`), and amount stability to predict future utility and subscription deductions with confidence scores (`75%..100%`). Inspect all predicted and confirmed bills anytime via the `See All` bottom sheet.

### 3. Local Voice Entry (`LocalVoiceParser`)
Tap the floating microphone and speak naturally (e.g., *"Spent fifteen hundred rupees at Zomato for food"*). Our on-device engine instantly:
- Converts Indian compound spoken numerals (`"fifteen hundred" -> 1500`).
- Fuzzy-matches merchant names against your existing history and category tables.
- Evaluates priority grammatical templates (`"<amount> for <merchant>"`, etc.).
- Auto-populates the expense form while visually flagging any low-confidence fields for rapid review.

### 4. Native SMS Auto-Parsing
On Android, our Kotlin `SmsReceiver` listens for bank debit notifications. It filters out non-financial messages using curated keyword lists (`constants/category_keywords.dart`), extracts amount and merchant data via regex, and securely transfers the record to our Dart service layer over a platform channel (`com.expensetracker/sms`).

### 5. First-Launch Sequential Permissions & Denial Resilience
When launched for the first time, Expense Tracker presents a polite, sequential in-app explanation dialog sequence (`Auto-Detect Bank SMS` $\rightarrow$ `Stay on Track` alerts) before requesting OS permissions. If permissions are denied, **the app never blocks or loops**—all manual entry and voice parsing remain 100% operational, and subtle status badges appear in `Privacy & Security` and `Notification Settings` with a 1-tap `openAppSettings()` recovery shortcut.

### 6. Security Suite & CSV Export
- **Biometric & PIN Lock**: Lock the app behind Fingerprint/FaceID or a custom PIN via `local_auth`.
- **Privacy Mode**: Toggle `Privacy Mode` from settings to instantly mask financial amounts across the dashboard with bullet characters (`••••`).
- **Complete Data Control**: Export your entire transaction history to a structured `.csv` file (`csv` + `path_provider`) and share it locally to any app (`share_plus`).

---

## 4. Local Setup & Run Instructions

Because Expense Tracker has **zero external dependencies, zero API keys, and zero cloud accounts**, running the project locally takes less than a minute.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.0.0 <4.0.0`)
- Android Studio / Xcode (`or physical device`)

### Step-by-Step Instructions

1. **Clone & Navigate**
   ```bash
   git clone <repo_url>
   cd expense_tracker
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate SQLite / Drift Database Code**
   Run `build_runner` to generate type-safe database DAOs (`database.g.dart`):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch the Application**
   ```bash
   flutter run
   ```
   *Note: No environment variables (`.env`), API keys, or configurations are required. The app will launch immediately.*

---

## 5. Demo Data Utility

To ensure evaluators and reviewers can immediately experience the app's full visual richness and intelligence without typing sample expenses by hand, Expense Tracker includes a built-in demo seeding engine (`DemoSeedService`).

### First-Launch Auto-Seeding
When the app launches with an empty database (`allTx.isEmpty`), it automatically populates:
- **20+ Realistic Indian Transactions**: Across categories (`Groceries`, `Travel`, `Car`, `Home`, `Other`) with merchants like `BigBasket`, `Zepto`, `Uber`, `Ola Cabs`, `Zomato`, and `Bescom Electricity`.
- **4 Recurring Monthly Subscriptions**: (`Netflix` ₹499, `Spotify` ₹149, `Gym Membership` ₹1200, `Broadband` ₹899) to immediately activate `GhostBillService` and populate the `Safe-to-Spend Speedometer`.

### Reset & Reload Demo Data
If you modify or delete transactions during testing and want to restore the pristine initial dashboard:
1. Navigate to **Profile Screen** (`bottom navigation bar`).
2. Tap the **Reset & Reload Demo Data** button (`danger variant`).
3. Confirm inside the destructive glassmorphism dialog. The app will wipe all tables and instantly re-seed clean sample data.

---

## 6. Known Limitations & Explicit Scope Decisions

In strict adherence to our local-first, privacy-preserving architecture (`AGENTS.md`), the following features are **explicitly out of scope by design**:

- **Cloud Sync / Cross-Device Replication**: Deliberately excluded. Syncing data across devices requires transmitting sensitive financial records over the network to a centralized database (`Firebase`, `Supabase`), directly violating our local-first privacy model.
- **Multi-Currency / Live Foreign Exchange Rates**: Deliberately excluded. Fetching live exchange rates requires continuous network polling against external financial APIs.
- **iOS SMS Auto-Parsing**: Apple iOS does not permit background SMS interception by third-party applications. On iOS, Expense Tracker operates seamlessly via **Local Voice Entry** and **Manual Entry**.
- **Third-Party Charting Suites**: We avoid bulky or telemetry-laden external chart packages (`fl_chart` is present in `pubspec.yaml` but completely unused across `lib/`) in favor of native, responsive custom canvas animations (`CustomPainter` & `design-aesthetics`).

---

<p align="center">
  <b>Expense Tracker</b> • Built with privacy, beauty, and local-first engineering.
</p>
