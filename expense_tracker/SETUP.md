# Manual Flutter Setup (macOS Security Workaround)

Your Mac has strict file protection enabled that's preventing both Homebrew and FVM Flutter installations from working.

## Solution: Manual Git Installation

```bash
# 1. Remove problematic installations
brew uninstall flutter 2>/dev/null
rm -rf ~/fvm 2>/dev/null

# 2. Install Flutter via Git
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$HOME/flutter/bin:$PATH"

# 3. Add to shell profile
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Run flutter doctor
flutter doctor -v

#5. Navigate to project and install dependencies
cd "/Users/khadyot/Desktop/Ongoing/Projects_AI IDE/Expense Tracker/expense_tracker"
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 6. Add your Gemini API key
# Edit lib/screens/add_expense_screen.dart line 26
# Replace: YOUR_GEMINI_API_KEY_HERE 
# With your key from: https://aistudio.google.com/app/apikey

# 7. Run the app
flutter run
```

## What This Does

- Installs Flutter to `~/flutter` (your home directory - no permission issues)
- Adds Flutter to your PATH
- Runs `build_runner` to generate the database code (`database.g.dart`)
- Launches the app

## If You Still Have Issues

Try giving Terminal full disk access:
1. System Settings → Privacy & Security → Full Disk Access
2. Click `+` and add Terminal.app
3. Restart Terminal and try again

## Project Structure

```
expense_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── database/database.dart       # Drift schema
│   ├── services/
│   │   ├── sms_service.dart        # SMS handling
│   │   └── voice_service.dart      # Voice + Gemini
│   ├── screens/
│   │   ├── home_screen.dart        # Dashboard with speedometer
│   │   └── add_expense_screen.dart # Voice input screen
│   ├── widgets/
│   │   ├── speedometer_widget.dart # Custom gauge
│   │   └── transaction_items.dart  # List items
│   └── theme/app_theme.dart        # Purple theme
└── android/app/src/main/kotlin/
    ├── SmsReceiver.kt              # Native SMS parser
    └── MainActivity.kt             # MethodChannel bridge
```
