import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomAuthTextField extends StatefulWidget {
  const CustomAuthTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.width,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final double? width;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  State<CustomAuthTextField> createState() => _CustomAuthTextFieldState();
}

class _CustomAuthTextFieldState extends State<CustomAuthTextField> {
  late bool _obscureText;

  static const _pillRadius = 32.0;
  static const _fieldHeight = 58.0;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(CustomAuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showPasswordToggle &&
        widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: widget.label == null ? widget.hintText : null,
      hintStyle: AppTextStyles.authFieldInput.copyWith(
        color: AppColors.white.withValues(alpha: 0.45),
      ),
      filled: true,
      fillColor: AppColors.authInputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      // Keeps pill height fixed; error text renders below (not inside) the field.
      constraints: const BoxConstraints(minHeight: _fieldHeight),
      isDense: false,
      suffixIcon: widget.showPasswordToggle
          ? IconButton(
              onPressed: () => setState(() => _obscureText = !_obscureText),
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.white.withValues(alpha: 0.75),
                size: 22,
              ),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorMaxLines: 2,
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 11,
        height: 1.3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isObscured =
        widget.showPasswordToggle ? _obscureText : widget.obscureText;

    final field = TextFormField(
      controller: widget.controller,
      obscureText: isObscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: AppTextStyles.authFieldInput,
      cursorColor: AppColors.white,
      decoration: _decoration(),
    );

    final Widget content = (widget.label == null) ? field : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label!, style: AppTextStyles.authFieldLabel),
        const SizedBox(height: 8),
        field,
      ],
    );

    return widget.width == null ? content : SizedBox(
      width: widget.width,
      child: content,
    );
  }
}
