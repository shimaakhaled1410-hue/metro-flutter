import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metro/utils/legal_texts.dart';

class LegalCard extends StatelessWidget {
  const LegalCard({super.key});

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.policy_outlined, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'close'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final String currentLang = Get.locale?.languageCode ?? 'en';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security_rounded, color: primaryColor),
                const SizedBox(width: 10),
                Text(
                  'legal_title'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text('privacy_policy'.tr),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                _showLegalDialog(
                  context,
                  'privacy_policy'.tr,
                  LegalTexts.getPrivacyPolicy(currentLang),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text('terms_conditions'.tr),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                _showLegalDialog(
                  context,
                  'terms_conditions'.tr,
                  LegalTexts.getTermsConditions(currentLang),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}