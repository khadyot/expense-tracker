import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../widgets/common/soft_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name);
    _limitController = TextEditingController(
        text: userProvider.monthlyLimit.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final monthlyLimit = double.parse(_limitController.text);

        await Provider.of<UserProvider>(context, listen: false).updateProfile(
          name: _nameController.text,
          monthlyLimit: monthlyLimit,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppTheme.textLight : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Avatar Ring
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.heroGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppTheme.backgroundDark : Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFEEEEEE),
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.heroGradientStart,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields Container
                SoftCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Full Name', isDark),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color:
                              isDark ? AppTheme.textLight : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight),
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Monthly Limit', isDark),
                      TextFormField(
                        controller: _limitController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color:
                              isDark ? AppTheme.textLight : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '60000',
                          hintStyle: TextStyle(
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight),
                          prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight),
                          suffixText: '₹',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button (Solid Black Pill per v3 spec)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
          color: isDark ? AppTheme.textLight : AppTheme.textDark,
        ),
      ),
    );
  }
}
