import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppController extends GetxController {
  static const String phoneNumber = '6282337577433';
  static const String defaultMessage = 'Halo Bakso Ojolali Cakwi, saya ingin memesan...';

  Future<void> openWhatsApp(BuildContext context, {String? customMessage}) async {
    final String message = customMessage ?? defaultMessage;
    final String encodedMessage = Uri.encodeComponent(message);

    final List<String> whatsappUrls = [
      'whatsapp://send?phone=$phoneNumber&text=$encodedMessage',
      'https://wa.me/$phoneNumber?text=$encodedMessage',
      'https://api.whatsapp.com/send?phone=$phoneNumber&text=$encodedMessage',
    ];

    bool opened = false;

    for (String urlString in whatsappUrls) {
      try {
        final Uri url = Uri.parse(urlString);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}