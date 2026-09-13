import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/legal/presentation/screens/legal_document_screen.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_tile.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: .05)),
        ],
      ),
      child: Column(
        children: [
          const SettingsTile(title: "المساعدة والدعم", icon: Icons.help_outline),
          const SettingsTile(title: "عن التطبيق", icon: Icons.info_outline),
          // Readable after signing up, not only during it. Both stores require
          // the documents to be reachable from inside the app, and a patient
          // who wants to check what they agreed to has nowhere else to look.
          SettingsTile(
            title: AppLegal.termsTitle,
            icon: Icons.description_outlined,
            onTap: () => _open(context, LegalDocument.terms),
          ),
          SettingsTile(
            title: AppLegal.privacyTitle,
            icon: Icons.privacy_tip_outlined,
            onTap: () => _open(context, LegalDocument.privacy),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, LegalDocument document) {
    Navigator.pushNamed(
      context,
      AppRoutes.legal,
      arguments: LegalDocumentArgs(document),
    );
  }
}
