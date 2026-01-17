import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final primary = colors.browcolor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Support & App Details"),
      ),
      body: CurveScreen(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- App Info Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.creamcolor.withOpacity(.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary.withOpacity(.1)),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/billova_logo.png",
                          height: 80,
                        ),
                        sh10,
                        const Text(
                          "Billova POS",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Version 1.0.0",
                          style: TextStyle(color: Colors.grey),
                        ),
                        sh20,
                        const Text(
                          "Empowering local businesses with a smart, offline-first billing solution. Print professional receipts, track sales, and manage inventory with ease.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  sh30,
                  const Text(
                    "CONNECT WITH US",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  sh10,

                  _supportTile(
                    icon: Icons.language_rounded,
                    title: "Official Website",
                    subtitle: "www.billova.com",
                    onTap: () => _launchUrl("https://www.billova.com"),
                  ),
                  _supportTile(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "support@billova.com",
                    onTap: () => _launchUrl("mailto:support@billova.com"),
                  ),
                  _supportTile(
                    icon: FontAwesomeIcons.whatsapp,
                    title: "WhatsApp",
                    subtitle: "+91 98765 43210",
                    onTap: () => _launchUrl("https://wa.me/919876543210"),
                  ),

                  sh30,
                  const Text(
                    "LEGAL",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  sh10,

                  _supportTile(
                    icon: Icons.policy_outlined,
                    title: "Privacy Policy",
                    onTap: () => _launchUrl("https://billova.com/privacy"),
                  ),
                  _supportTile(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    onTap: () => _launchUrl("https://billova.com/terms"),
                  ),

                  sh40,
                  Center(
                    child: Text(
                      "Made with ❤️ for Entrepreneurs",
                      style: TextStyle(
                        color: primary.withOpacity(.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  sh20,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors().browcolor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
