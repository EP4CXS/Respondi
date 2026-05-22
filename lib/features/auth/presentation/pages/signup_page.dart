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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
          key: _controller.signupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Center(child: AppLogo(size: logoSize)),
              const SizedBox(height: 20),
              Text('Sign Up', style: AppTextStyles.authTitle),
              const SizedBox(height: 24),
              CustomAuthTextField(
                controller: _controller.fullNameController,
                hintText: 'Fullname',
                textInputAction: TextInputAction.next,
                validator: _controller.validateFullName,
              ),
              const SizedBox(height: 14),
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
                textInputAction: TextInputAction.next,
                validator: _controller.validatePassword,
              ),
              const SizedBox(height: 14),
              CustomAuthTextField(
                controller: _controller.confirmPasswordController,
                hintText: 'Confirm password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _controller.validateConfirmPassword,
                onFieldSubmitted: (_) => _controller.register(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Sign Up',
                isLoading: _controller.isLoading,
                onPressed: _controller.register,
              ),
              const SizedBox(height: 24),
              const AuthDivider(),
              const SizedBox(height: 24),
              GoogleButton(
                isLoading: _controller.isLoading,
                onPressed: _controller.signInWithGoogle,
              ),
              const SizedBox(height: 28),
              AuthFooterText(
                prefix: 'Already have an account? ',
                actionLabel: 'Sign in',
                onActionTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
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
