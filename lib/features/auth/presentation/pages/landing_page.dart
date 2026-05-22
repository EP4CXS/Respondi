import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/auth_footer_text.dart';
import '../../../../core/widgets/background_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Edited: Increased logo size (was 22% height, max 160 → now 28%, max 200)
    final logoSize = (screenHeight * 0.28).clamp(140.0, 200.0);

    // Edited: Button width ~82% of screen (reference uses ~80–85%, not full width)
    final buttonWidth = screenWidth * 0.62;

    return BackgroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.16),
                      Text(
                        'Your AI health assistant for\n'
                        'first aid, symptoms, and\n'
                        'emergency guidance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Edited: Shift logo + app name slightly toward the top
                  Transform.translate(
                    offset: const Offset(0, -42),
                    child: Column(
                      children: [
                        AppLogo(size: logoSize),
                        const SizedBox(height: 20),
                        Text('RESPONDI', style: AppTextStyles.appTitle),
                      ],
                    ),
                  ),
                  // Edited: Narrower button + nudge CTA block up + less bottom padding
                  Transform.translate(
                    offset: const Offset(0, -90),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: buttonWidth,
                            child: PrimaryButton(
                              label: 'Get Started',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.signup,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthFooterText(
                          prefix: 'Already have an account? ',
                          actionLabel: 'Sign in',
                          onActionTap: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                        ),
                        // Edited: Reduced bottom gap (was 4% → 2%) to move button/footer up
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
