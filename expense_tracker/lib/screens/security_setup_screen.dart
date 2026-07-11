import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/security_service.dart';

class SecuritySetupScreen extends StatefulWidget {
  final AppLockType type;

  const SecuritySetupScreen({super.key, required this.type});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isConfirming = false;
  String _errorMessage = '';

  void _handleNext() async {
    if (!_isConfirming) {
      if (_controller.text.isEmpty) {
        setState(() => _errorMessage = 'Please enter a ${widget.type.name}');
        return;
      }
      setState(() {
        _isConfirming = true;
        _errorMessage = '';
      });
    } else {
      if (_controller.text != _confirmController.text) {
        setState(() =>
            _errorMessage = '${widget.type.name.toUpperCase()}s do not match');
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (widget.type == AppLockType.pin) {
        await SecurityService.savePin(_controller.text);
      } else {
        await SecurityService.savePassword(_controller.text);
      }

      await userProvider.updateSecuritySettings(appLockType: widget.type);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${widget.type.name.toUpperCase()} set successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isConfirming
        ? 'Confirm ${widget.type.name}'
        : 'Set ${widget.type.name}';
    final label = widget.type == AppLockType.pin
        ? 'Enter 4-6 digit PIN'
        : 'Enter Password';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_isConfirming) {
              setState(() {
                _isConfirming = false;
                _confirmController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _isConfirming ? _confirmController : _controller,
                  obscureText: true,
                  keyboardType: widget.type == AppLockType.pin
                      ? TextInputType.number
                      : TextInputType.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText:
                        widget.type == AppLockType.pin ? '••••' : 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_isConfirming ? 'Save' : 'Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
