import 'package:flutter/material.dart';
import '../../../../app/router/app_router.dart';

import '../../../../app/app.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';
import '../widgets/auth_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _nameController.dispose();
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
      context.resetToHome();
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
            kicker: 'Create profile',
            title: 'Build your personal rhythm',
            subtitle:
                'Create an account to keep habits, check-ins, and daily progress in one calm space.',
            isLoading: state.isLoading,
            errorText: state is AuthFailureState ? state.message : null,
            primaryLabel: 'Register',
            footerNote:
                'You can start with just a name, email, and password. Everything else can grow later.',
            onPrimaryPressed: () {
              _authController.signUp(
                name: _nameController.text,
                email: _emailController.text,
                password: _passwordController.text,
              );
            },
            secondaryAction: TextButton(
              onPressed: state.isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Back to login'),
            ),
            fields: [
              TextField(
                controller: _nameController,
                onChanged: (_) => _authController.clearMessage(),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
                  hintText: 'Create a password',
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
