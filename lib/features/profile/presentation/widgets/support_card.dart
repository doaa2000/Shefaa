import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/legal/presentation/screens/legal_document_screen.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/about_app_dialog.dart';
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
          // "المساعدة والدعم" and "عن المطور" used to be here and led nowhere.
          // There is no support channel to send anybody to yet; a row that does
          // nothing when a patient needs help is worse than no row.
          SettingsTile(
            title: "عن التطبيق",
            icon: Icons.info_outline,
            onTap: () => showAboutAppDialog(context),
          ),
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
