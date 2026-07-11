import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isAuthenticating = false;
  final _inputController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAppLockEnabled) {
        setState(() {
          _isLocked = true;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  Future<void> _checkLock() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If lock is disabled or running on web, don't show the lock screen
    if (!userProvider.isAppLockEnabled || kIsWeb) {
      setState(() {
        _isLocked = false;
      });
      return;
    }

    if (_isLocked && !_isAuthenticating) {
      if (userProvider.appLockType == AppLockType.biometric) {
        _authenticateBiometric();
      }
    }
  }

  Future<void> _authenticateBiometric() async {
    setState(() {
      _isAuthenticating = true;
    });

    final authenticated = await AuthService.authenticate();

    if (authenticated) {
      setState(() {
        _isLocked = false;
        _isAuthenticating = false;
      });
    } else {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _verifyCredential() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool authenticated = false;

    if (userProvider.appLockType == AppLockType.pin) {
      authenticated = await SecurityService.verifyPin(_inputController.text);
    } else if (userProvider.appLockType == AppLockType.password) {
      authenticated =
          await SecurityService.verifyPassword(_inputController.text);
    }

    if (authenticated) {
      setState(() {
        _isLocked = false;
        _errorMessage = '';
        _inputController.clear();
      });
    } else {
      setState(() {
        _errorMessage =
            'Incorrect ${userProvider.appLockType.name.toUpperCase()}';
        _inputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'App Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.appLockType == AppLockType.biometric) {
                    return ElevatedButton.icon(
                      onPressed: _authenticateBiometric,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Unlock with Biometrics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          TextField(
                            controller: _inputController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            keyboardType:
                                userProvider.appLockType == AppLockType.pin
                                    ? TextInputType.number
                                    : TextInputType.text,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                letterSpacing: 8),
                            decoration: InputDecoration(
                              hintText:
                                  userProvider.appLockType == AppLockType.pin
                                      ? '••••'
                                      : 'Password',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            onSubmitted: (_) => _verifyCredential(),
                          ),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _errorMessage,
                                style:
                                    const TextStyle(color: Colors.orangeAccent),
                              ),
                            ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: _verifyCredential,
                            child: const Text('Unlock',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
