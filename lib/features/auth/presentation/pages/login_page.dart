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

  Future<void> _onLogIn() async {
    await _controller.login();
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
    final logoSize = (screenHeight * 0.11).clamp(64.0, 88.0);

    final formContentWidth = screenWidth * 0.76;


    final loginButtonWidth = screenWidth * 0.40;

    return BackgroundScaffold(
      resizeToAvoidBottomInset: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _controller.loginFormKey,
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Edited: More top space — pushes logo down (was 5% → 11% of screen height)
                      SizedBox(height: screenHeight * 0.11),
                      // Edited: Tap logo → back to landing (homepage)
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
                      const SizedBox(height: 42),
                      // Edited: Form block uses fixed width so fields are not full-screen wide
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: formContentWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign in',
                                style: AppTextStyles.authTitleMono,
                              ),
                              const SizedBox(height: 44),
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
                                showPasswordToggle: true,
                                textInputAction: TextInputAction.done,
                                validator: _controller.validatePassword,
                              ),
                              // Edited: Log in button below password — width set by loginButtonWidth above
                              const SizedBox(height: 50),
                              Align(
                                alignment: Alignment.center,
                                child: PrimaryButton(
                                  label: 'Log in',
                                  width: loginButtonWidth, // Edited: button width control
                                  isLoading: _controller.isLoading,
                                  onPressed: _onLogIn,
                                ),
                              ),
                              // Edited: Footer closer to Log in (removed or + Google)
                              const SizedBox(height: 40),
                              AuthFooterText(
                                italic: true,
                                prefix: "Don't have an account? ",
                                actionLabel: 'Sign up',
                                onActionTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.signup,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
