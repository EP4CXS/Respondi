import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class AuthFooterText extends StatelessWidget {
  const AuthFooterText({
    super.key,
    required this.prefix,
    required this.actionLabel,
    required this.onActionTap,
    this.italic = false,
  });

  final String prefix;
  final String actionLabel;
  final VoidCallback onActionTap;

  /// Sign-in reference uses italic footer with bold italic link.
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        italic ? AppTextStyles.authFooterItalic : AppTextStyles.footer;
    final actionStyle = italic
        ? AppTextStyles.authFooterBoldItalic
        : AppTextStyles.footerBold;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: actionLabel,
            style: actionStyle,
            recognizer: TapGestureRecognizer()..onTap = onActionTap,
          ),
        ],
      ),
    );
  }
}
