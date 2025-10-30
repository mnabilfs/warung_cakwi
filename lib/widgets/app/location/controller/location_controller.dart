import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationController extends GetxController {
  static const double latitude = -7.901906;
  static const double longitude = 112.582788;

  final String title = 'Lokasi Warung Cakwi';
  final String address = 'Jl. Drs. Moh. Hatta 141-143\nPendem, Kec. Junrejo, Kota Malang, Jawa Timur';
  final String nearbyPlaces = 'Dekat dengan:\n• SD Negeri Pendem 01\n• MEGG Transport\n• Di Depan Sawah';

  Future<void> openGoogleMaps(BuildContext context) async {
    final List<String> urlSchemes = [
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      'geo:$latitude,$longitude?q=$latitude,$longitude(Warung+Cakwi)',
      'https://maps.google.com/?q=$latitude,$longitude',
    ];

    bool opened = false;

    for (String urlString in urlSchemes) {
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
          content: Text('Tidak dapat membuka Google Maps. Pastikan aplikasi Maps terinstall.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}