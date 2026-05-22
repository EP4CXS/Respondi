import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

void showAuthMessage(
  BuildContext context,
  String? message, {
  bool isSuccess = false,
}) {
  if (message == null || message.isEmpty) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? const Color(0xFF2E7D32) : AppColors.primaryPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
