import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/auth_divider.dart';
import '../../../../core/widgets/auth_footer_text.dart';
import '../../../../core/widgets/background_scaffold.dart';
import '../../../../core/widgets/custom_auth_text_field.dart';
import '../../../../core/widgets/google_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final logoSize = (screenHeight * 0.1).clamp(56.0, 80.0);

    return BackgroundScaffold(
      resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Center(child: AppLogo(size: logoSize)),
              const SizedBox(height: 24),
              Text('Sign in', style: AppTextStyles.authTitle),
              const SizedBox(height: 28),
              CustomAuthTextField(
                controller: _controller.emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _controller.validateEmail,
              ),
              const SizedBox(height: 14),
              CustomAuthTextField(
                controller: _controller.passwordController,
                hintText: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _controller.validatePassword,
                onFieldSubmitted: (_) => _controller.login(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Sign in',
                isLoading: _controller.isLoading,
                onPressed: _controller.login,
              ),
              const SizedBox(height: 24),
              const AuthDivider(),
              const SizedBox(height: 24),
              GoogleButton(
                isLoading: _controller.isLoading,
                onPressed: _controller.signInWithGoogle,
              ),
              const SizedBox(height: 32),
              AuthFooterText(
                prefix: "Don't have an account? ",
                actionLabel: 'Sign up',
                onActionTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
