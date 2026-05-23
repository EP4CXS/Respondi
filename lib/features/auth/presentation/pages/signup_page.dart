import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/session/chat_session_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/auth_footer_text.dart';
import '../../../../core/widgets/background_scaffold.dart';
import '../../../../core/widgets/custom_auth_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';
import '../utils/auth_feedback.dart';

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

  Future<void> _onSignUp() async {
    await _controller.register();
    if (!mounted) return;
    if (_controller.currentUser != null) {
      ChatSessionManager.beginUserSession(_controller.currentUser!.id);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.chat,
        (route) => false,
        arguments: _controller.currentUser,
      );
      return;
    }
    showAuthMessage(context, _controller.errorMessage);
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoSize = (screenHeight * 0.1).clamp(56.0, 90.0);

    // Edited: Sign Up button width — same as Log in on login_page.dart (change 0.60 to adjust)
    final signUpButtonWidth = screenWidth * 0.60;

    return BackgroundScaffold(
      resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _controller.signupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.09),
              Center(
                child: AppLogo(
                  size: logoSize,
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.landing,
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text('Sign Up', style: AppTextStyles.authTitleMono),
              const SizedBox(height: 36),
              CustomAuthTextField(
                label: 'Fullname',
                controller: _controller.fullNameController,
                textInputAction: TextInputAction.next,
                validator: _controller.validateFullName,
              ),
              const SizedBox(height: 22),
              CustomAuthTextField(
                label: 'Email',
                controller: _controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _controller.validateEmail,
              ),
              const SizedBox(height: 22),
              CustomAuthTextField(
                label: 'Password',
                controller: _controller.passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: _controller.validatePassword,
              ),
              const SizedBox(height: 22),
              CustomAuthTextField(
                label: 'Confirm password',
                controller: _controller.confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _controller.validateConfirmPassword,
                onFieldSubmitted: (_) => _controller.register(),
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: PrimaryButton(
                  label: 'Sign Up',
                  width: signUpButtonWidth, // Edited: button width control
                  isLoading: _controller.isLoading,
                  onPressed: _onSignUp,
                ),
              ),
              // Edited: Footer closer to Sign Up (removed or + Google)
              const SizedBox(height: 40),
              AuthFooterText(
                italic: true,
                prefix: 'Already have an account? ',
                actionLabel: 'Sign in',
                onActionTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
