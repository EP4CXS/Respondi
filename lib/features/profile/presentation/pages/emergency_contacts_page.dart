import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/red_gradient_scaffold.dart';

class _EmergencyContact {
  const _EmergencyContact({
    required this.label,
    required this.number,
  });

  final String label;
  final String number;
}

const _contacts = [
  _EmergencyContact(label: '🚑 Ambulance', number: '0950 868 3787'),
  _EmergencyContact(
    label: '👮 Philippine National Police',
    number: '0939 917 3672',
  ),
  _EmergencyContact(
    label: '🔥 Bureau of Fire Protection',
    number: '0931 721 8756',
  ),
  _EmergencyContact(label: '🛟 MDRRMC', number: '0946 748 7064'),
  _EmergencyContact(
    label: '🏥 Municipal Health Office',
    number: '0956 026 2246',
  ),
];

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RedGradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            Text(
              'EMERGENCY',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 1,
              ),
            ),
            Text(
              'CONTACTS',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 28),
            for (var i = 0; i < _contacts.length; i++) ...[
              if (i > 0) const SizedBox(height: 22),
              _EmergencyContactCard(contact: _contacts[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard({required this.contact});

  final _EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, left: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.profileFieldFill,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              contact.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.profileContactHeader,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              contact.label,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
