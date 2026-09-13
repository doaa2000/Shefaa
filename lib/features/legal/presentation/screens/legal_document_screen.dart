import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';

/// Which document to show. The screen is the same either way; only the words
/// differ, and two screens that differ only in a string are one screen.
enum LegalDocument { terms, privacy }

class LegalDocumentArgs {
  final LegalDocument document;

  const LegalDocumentArgs(this.document);
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.args});

  final LegalDocumentArgs args;

  static const String routeName = '/legal';

  @override
  Widget build(BuildContext context) {
    final isTerms = args.document == LegalDocument.terms;

    return Scaffold(
      appBar: CustomAppBar(title: isTerms ? AppLegal.termsTitle : AppLegal.privacyTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Constants.padding),
          child: Text(
            (isTerms ? AppLegal.termsBody : AppLegal.privacyBody).trim(),
            style: TextStyles.meduim14.copyWith(height: 1.9),
          ),
        ),
      ),
    );
  }
}
