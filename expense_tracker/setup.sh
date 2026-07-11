#!/bin/bash

# Expense Tracker - One-Click Setup Script
# This script installs Flutter via Git and sets up the project

set -e  # Exit on error

echo "🚀 Starting Expense Tracker Setup..."
echo ""

# Step 1: Check if Flutter exists
if command -v flutter &> /dev/null && flutter --version 2>/dev/null; then
    echo "✅ Flutter already installed"
    flutter --version
else
    echo "📦 Installing Flutter via Git..."
    
    # Remove old installations
    rm -rf ~/flutter 2>/dev/null || true
    
    # Clone Flutter
    cd ~
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    
    # Update PATH
    export PATH="$HOME/flutter/bin:$PATH"
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
    
    echo "✅ Flutter installed to ~/flutter"
fi

# Step 2: Run Flutter Doctor
echo ""
echo "🔍 Running Flutter Doctor..."
flutter doctor -v

# Step 3: Project Setup
echo ""
echo "📱 Setting up project..."
cd "/Users/khadyot/Desktop/Ongoing/Projects_AI IDE/Expense Tracker/expense_tracker"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate database code
echo "🔨 Generating database code..."
dart run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Add your Gemini API key:"
echo "   Edit: lib/screens/add_expense_screen.dart (line 26)"
echo "   Replace: YOUR_GEMINI_API_KEY_HERE"
echo "   Get key: https://aistudio.google.com/app/apikey"
echo ""
echo "2. Run the app:"
echo "   cd '/Users/khadyot/Desktop/Ongoing/Projects_AI IDE/Expense Tracker/expense_tracker'"
echo "   flutter run"
echo ""
echo "🎉 Happy tracking!"
