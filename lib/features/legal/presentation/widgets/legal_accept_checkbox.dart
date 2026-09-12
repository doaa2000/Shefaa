import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/legal/presentation/screens/legal_document_screen.dart';

/// The terms and privacy tick on the registration form.
///
/// Its own box, beside the health-data one rather than inside it. Agreeing to
/// use a service and agreeing to have your health information stored are two
/// decisions, and a single tick that covers both is not an explicit consent to
/// the second one -- which is the whole reason the health box exists.
///
/// The two names are links into the full text. A checkbox that claims you read
/// something you were never shown is worth nothing.
class LegalAcceptCheckbox extends StatelessWidget {
  const LegalAcceptCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyles.bold12.copyWith(
      color: AppColors.primaryColor,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryColor,
    );
    final plainStyle = TextStyles.meduim12.copyWith(
      color: Colors.grey.shade800,
      height: 1.6,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          width: 28,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primaryColor,
            onChanged: (next) => onChanged(next ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onChanged(!value),
                  child: Text('أوافق على ', style: plainStyle),
                ),
                GestureDetector(
                  onTap: () => _open(context, LegalDocument.terms),
                  child: Text(AppLegal.termsTitle, style: linkStyle),
                ),
                Text(' و', style: plainStyle),
                GestureDetector(
                  onTap: () => _open(context, LegalDocument.privacy),
                  child: Text(AppLegal.privacyTitle, style: linkStyle),
                ),
              ],
            ),
          ),
        ),
      ],
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
