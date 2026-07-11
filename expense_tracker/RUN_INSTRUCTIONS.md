# How to Run the App

## Option A: Connect Android Phone (Recommended)

1. **Enable Developer Options**
   - Go to **Settings > About Phone**
   - Tap **Build Number** 7 times until it says "You are a developer"

2. **Enable USB Debugging**
   - Go to **Settings > System > Developer Options**
   - Turn on **USB Debugging**

3. **Connect to Mac**
   - Plug phone in via USB
   - On phone: Tap "Allow USB debugging" popup (Check "Always allow")

4. **Install Android Licenses & SDK**
   (Run these commands in terminal)
   ```bash
   # Accept licenses
   yes | flutter doctor --android-licenses
   
   # Update SDK (if needed)
   ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

5. **Run App**
   ```bash
   flutter run
   ```

## Option B: Run on macOS (Desktop)

If you don't have an Android phone handy:

1. **Enable macOS Support**
   ```bash
   flutter config --enable-macos-desktop
   flutter create --platforms=macos .
   ```

2. **Run App**
   ```bash
   flutter run -d macos
   ```

## Troubleshooting

**"No devices found"**
- Check USB cable
- Ensure USB Debugging is ON
- Run `flutter devices` to check visibility

**"Operation not permitted"**
- If you see permission errors, run:
  ```bash
  sudo chown -R $(whoami) ~/flutter
  xattr -r -d com.apple.quarantine ~/flutter
  ```
