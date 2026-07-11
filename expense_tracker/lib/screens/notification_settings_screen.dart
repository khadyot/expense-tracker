import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // We'll update state via the provider, but locally track for UI constraints if needed.
  // Actually, we can drive pure UI from provider.

  Future<void> _pickTime(BuildContext context, UserProvider user) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: user.dailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != user.dailyReminderTime) {
      user.updateNotificationSettings(
        isDailyReminderEnabled: user.isDailyReminderEnabled,
        dailyReminderTime: picked,
        isBudgetAlertsEnabled: user.isBudgetAlertsEnabled,
        budgetThreshold: user.budgetThreshold,
        isSmartInsightsEnabled: user.isSmartInsightsEnabled,
      );

      if (user.isDailyReminderEnabled) {
        NotificationService().scheduleDailyReminder(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize notification service if not done already (useful if coming here first time)
    // In a real app, do this at app startup.
    NotificationService().initialize();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundLight.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, user, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    _buildNotifStatusTile(context),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      children: [
                        _SwitchTile(
                          title: 'Daily Reminder',
                          subtitle: 'Get reminded to log your expenses',
                          icon: Icons.access_alarm_rounded,
                          value: user.isDailyReminderEnabled,
                          onChanged: (value) {
                            user.updateNotificationSettings(
                              isDailyReminderEnabled: value,
                              dailyReminderTime: user.dailyReminderTime,
                              isBudgetAlertsEnabled: user.isBudgetAlertsEnabled,
                              budgetThreshold: user.budgetThreshold,
                              isSmartInsightsEnabled:
                                  user.isSmartInsightsEnabled,
                            );
                            if (value) {
                              NotificationService().scheduleDailyReminder(
                                  user.dailyReminderTime);
                            } else {
                              NotificationService().cancelDailyReminder();
                            }
                          },
                        ),
                        if (user.isDailyReminderEnabled) ...[
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 56, right: 16),
                            title: const Text(
                              'Reminder Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.dailyReminderTime.format(context),
                                style: const TextStyle(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => _pickTime(context, user),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 56, right: 16),
                            title: const Text(
                              'Test Notification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                            trailing: const Icon(
                                Icons.notifications_active_outlined,
                                color: AppTheme.primaryPurple),
                            onTap: () async {
                              await NotificationService()
                                  .showInstantNotification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Test notification sent! 🚀')),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Smart Alerts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      children: [
                        _SwitchTile(
                          title: 'Budget Thresholds',
                          subtitle: 'Alert when you reach 80% limit',
                          icon: Icons.speed_rounded,
                          value: user.isBudgetAlertsEnabled,
                          onChanged: (value) {
                            user.updateNotificationSettings(
                              isDailyReminderEnabled:
                                  user.isDailyReminderEnabled,
                              dailyReminderTime: user.dailyReminderTime,
                              isBudgetAlertsEnabled: value,
                              isSmartInsightsEnabled:
                                  user.isSmartInsightsEnabled,
                            );
                          },
                        ),
                        if (user.isBudgetAlertsEnabled) ...[
                          const Divider(height: 1, indent: 56),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 56, right: 24, top: 12, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Alert Threshold',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      '${(user.budgetThreshold * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppTheme.primaryPurple,
                                    inactiveTrackColor:
                                        AppTheme.primaryPurple.withOpacity(0.2),
                                    thumbColor: AppTheme.primaryPurple,
                                    overlayColor:
                                        AppTheme.primaryPurple.withOpacity(0.1),
                                  ),
                                  child: Slider(
                                    value: user.budgetThreshold,
                                    min: 0.1,
                                    max: 1.0,
                                    divisions: 18, // Steps of 5%
                                    label:
                                        '${(user.budgetThreshold * 100).toInt()}%',
                                    onChanged: (value) {
                                      user.updateNotificationSettings(
                                        isDailyReminderEnabled:
                                            user.isDailyReminderEnabled,
                                        dailyReminderTime:
                                            user.dailyReminderTime,
                                        isBudgetAlertsEnabled:
                                            user.isBudgetAlertsEnabled,
                                        budgetThreshold: value,
                                        isSmartInsightsEnabled:
                                            user.isSmartInsightsEnabled,
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  'You will be notified when you reach ${(user.budgetThreshold * 100).toInt()}% of your limit.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 1, indent: 56),
                        _SwitchTile(
                          title: 'Smart Insights',
                          subtitle: 'Recurring bills & weekly summary',
                          icon: Icons.auto_graph_rounded,
                          value: user.isSmartInsightsEnabled,
                          onChanged: (value) {
                            user.updateNotificationSettings(
                              isDailyReminderEnabled:
                                  user.isDailyReminderEnabled,
                              dailyReminderTime: user.dailyReminderTime,
                              isBudgetAlertsEnabled: user.isBudgetAlertsEnabled,
                              budgetThreshold: user.budgetThreshold,
                              isSmartInsightsEnabled: value,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotifStatusTile(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: Permission.notification.status,
      builder: (context, snapshot) {
        final isGranted = snapshot.data?.isGranted == true;
        if (isGranted) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningSurfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warningBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_off_outlined,
                  color: AppColors.warningBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications Inactive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permission denied. Reminders will not appear until allowed in OS settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGray.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () => openAppSettings(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: AppTheme.glassmorphism(
        color: Colors.white,
        opacity: 0.6,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryPurple,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textGray,
              ),
            )
          : null,
    );
  }
}
