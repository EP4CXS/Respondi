import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/red_gradient_scaffold.dart';
import '../../../auth/domain/entities/app_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.user});

  final AppUser? user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  bool _isEditing = false;

  String get _displayName {
    final name = widget.user?.fullName ?? 'Joe Dope';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 2) return name;
    return '${parts.first} ${parts[1]}';
  }

  String get _initialFullName =>
      widget.user?.fullName ?? 'Joe Dope T. Cute';

  String get _initialEmail => widget.user?.email ?? 'joe@gmail.com';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: _initialFullName);
    _emailController = TextEditingController(text: _initialEmail);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEditing() => setState(() => _isEditing = true);

  void _save() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile saved',
          style: GoogleFonts.spaceMono(color: AppColors.white),
        ),
        backgroundColor: AppColors.profileButtonRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RedGradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _ProfileAvatar(),
            const SizedBox(height: 20),
            Text(
              _displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 36),
            _ProfileField(
              label: 'Fullname',
              controller: _fullNameController,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 22),
            _ProfileField(
              label: 'Gmail',
              controller: _emailController,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: 'edit',
                  backgroundColor: AppColors.profileButtonRed,
                  onPressed: _startEditing,
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  label: 'Save',
                  backgroundColor: AppColors.black,
                  onPressed: _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 5),
        color: AppColors.black,
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.white,
        size: 64,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final fieldStyle = GoogleFonts.spaceMono(
      color: AppColors.black,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.profileFieldFill,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: isEditing
              ? TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: fieldStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  controller.text,
                  textAlign: TextAlign.center,
                  style: fieldStyle,
                ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
