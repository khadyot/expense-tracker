import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLockType { none, biometric, pin, password }

class UserProvider extends ChangeNotifier {
  UserProvider() {
    _loadPreferences();
  }

  String _name = 'Ethan';
  String _currency = '₹'; // Default to Rupees
  double _monthlyLimit = 60000.0; // Default monthly limit (~2000/day)

  // Getters
  String get name => _name;
  String get currency => _currency;

  double get monthlyLimit => _monthlyLimit;

  double get dailyLimit {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return _monthlyLimit / daysInMonth;
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Notification Settings
  bool _isDailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isBudgetAlertsEnabled = false;
  double _budgetThreshold = 0.8; // Default to 80%
  bool _isSmartInsightsEnabled = false;

  // Privacy & Security Settings
  bool _isPrivacyModeEnabled = false;
  AppLockType _appLockType = AppLockType.none;

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  bool get isBudgetAlertsEnabled => _isBudgetAlertsEnabled;
  double get budgetThreshold => _budgetThreshold;
  bool get isSmartInsightsEnabled => _isSmartInsightsEnabled;
  bool get isPrivacyModeEnabled => _isPrivacyModeEnabled;
  AppLockType get appLockType => _appLockType;
  bool get isAppLockEnabled => _appLockType != AppLockType.none;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? 'Ethan';
    _currency = '₹'; // Enforce Rupees
    _monthlyLimit = prefs.getDouble('user_monthly_limit') ?? 60000.0;

    _isDailyReminderEnabled =
        prefs.getBool('notifications_daily_reminder') ?? false;
    final reminderHour = prefs.getInt('notifications_reminder_hour') ?? 20;
    final reminderMinute = prefs.getInt('notifications_reminder_minute') ?? 0;
    _dailyReminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);

    _isBudgetAlertsEnabled =
        prefs.getBool('notifications_budget_alerts') ?? false;
    _budgetThreshold = prefs.getDouble('notifications_budget_threshold') ?? 0.8;

    _isSmartInsightsEnabled =
        prefs.getBool('notifications_smart_insights') ?? false;

    _isPrivacyModeEnabled = prefs.getBool('security_privacy_mode') ?? false;
    final lockIndex = prefs.getInt('security_app_lock_type') ?? 0;
    _appLockType = AppLockType.values[lockIndex];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required double monthlyLimit,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _name = name;
    _currency = '₹';
    _monthlyLimit = monthlyLimit;

    await prefs.setString('user_name', name);
    // Removed email saving
    await prefs.setString('user_currency', '₹');
    await prefs.setDouble('user_monthly_limit', monthlyLimit);

    notifyListeners();
  }

  Future<void> updateNotificationSettings({
    required bool isDailyReminderEnabled,
    required TimeOfDay dailyReminderTime,
    required bool isBudgetAlertsEnabled,
    double? budgetThreshold,
    required bool isSmartInsightsEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _isDailyReminderEnabled = isDailyReminderEnabled;
    _dailyReminderTime = dailyReminderTime;
    _isBudgetAlertsEnabled = isBudgetAlertsEnabled;
    if (budgetThreshold != null) {
      _budgetThreshold = budgetThreshold;
    }
    _isSmartInsightsEnabled = isSmartInsightsEnabled;

    await prefs.setBool('notifications_daily_reminder', isDailyReminderEnabled);
    await prefs.setInt('notifications_reminder_hour', dailyReminderTime.hour);
    await prefs.setInt(
        'notifications_reminder_minute', dailyReminderTime.minute);
    await prefs.setBool('notifications_budget_alerts', isBudgetAlertsEnabled);
    await prefs.setDouble('notifications_budget_threshold', _budgetThreshold);
    await prefs.setBool('notifications_smart_insights', isSmartInsightsEnabled);

    notifyListeners();
  }

  Future<void> updateSecuritySettings({
    bool? isPrivacyModeEnabled,
    AppLockType? appLockType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (isPrivacyModeEnabled != null) {
      _isPrivacyModeEnabled = isPrivacyModeEnabled;
      await prefs.setBool('security_privacy_mode', isPrivacyModeEnabled);
    }
    if (appLockType != null) {
      _appLockType = appLockType;
      await prefs.setInt('security_app_lock_type', appLockType.index);
    }

    notifyListeners();
  }
}
