import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final VoidCallback _authListener;
  late final AuthController _authController;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _authListener = _handleAuthStateChanged;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isSubscribed) {
      return;
    }

    _authController = context.authController;
    _authController.addListener(_authListener);
    _isSubscribed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _authController.checkAuthState();
    });
  }

  @override
  void dispose() {
    if (_isSubscribed) {
      _authController.removeListener(_authListener);
    }
    super.dispose();
  }

  void _handleAuthStateChanged() {
    if (!mounted) {
      return;
    }

    final state = _authController.state;
    if (state is AuthAuthenticatedState) {
      context.replaceWithHome();
    } else if (state is AuthUnauthenticatedState) {
      context.replaceWithLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4EFE6), Color(0xFFE8F0EA), Color(0xFFF6E4D4)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(
                          Icons.track_changes_rounded,
                          color: colorScheme.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'FocusBoard',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Daily habits, mood check-ins, and small steps that stay visible.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.72),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const AppLoader(label: 'Checking session...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
