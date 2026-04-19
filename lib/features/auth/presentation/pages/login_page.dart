import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../app/router/app_router.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';
import '../widgets/auth_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'demo@focusboard.dev');
  final _passwordController = TextEditingController(text: 'password123');
  late final VoidCallback _authListener;
  late final AuthController _authController;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _authListener = _handleAuthChanges;
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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    if (_isSubscribed) {
      _authController.removeListener(_authListener);
    }
    super.dispose();
  }

  void _handleAuthChanges() {
    if (!mounted) {
      return;
    }

    if (_authController.state is AuthAuthenticatedState) {
      context.replaceWithHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        final state = _authController.state;

        return Scaffold(
          appBar: AppBar(),
          body: AuthForm(
            kicker: 'FocusBoard',
            title: 'Welcome back',
            subtitle:
                'Sign in to continue tracking your habits, daily mood, and progress without losing momentum.',
            isLoading: state.isLoading,
            errorText: state is AuthFailureState ? state.message : null,
            primaryLabel: 'Sign in',
            footerNote: 'Demo access: demo@focusboard.dev / password123',
            onPrimaryPressed: () {
              _authController.signIn(
                email: _emailController.text,
                password: _passwordController.text,
              );
            },
            secondaryAction: TextButton(
              onPressed: state.isLoading ? null : context.pushRegister,
              child: const Text('Create account'),
            ),
            fields: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _authController.clearMessage(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => _authController.clearMessage(),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
