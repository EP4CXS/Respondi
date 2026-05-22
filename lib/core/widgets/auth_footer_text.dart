import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class AuthFooterText extends StatelessWidget {
  const AuthFooterText({
    super.key,
    required this.prefix,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String prefix;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.footer,
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: actionLabel,
            style: AppTextStyles.footerBold,
            recognizer: TapGestureRecognizer()..onTap = onActionTap,
          ),
        ],
      ),
    );
  }
}
