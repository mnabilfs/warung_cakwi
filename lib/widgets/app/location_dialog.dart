import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog untuk menampilkan informasi lokasi toko
class LocationDialog {
  // Koordinat lokasi Warung Cakwi
  static const double latitude = -7.901906;
  static const double longitude = 112.582788;

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Row(
          children: const [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Lokasi Warung Cakwi',
              style: TextStyle(color: Color(0xFFD4A017)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jl. Drs. Moh. Hatta 141-143\nPendem, Kec. Junrejo, Kota Malang, Jawa Timur',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 15),
            Text(
              'Dekat dengan:\n• SD Negeri Pendem 01\n• MEGG Transport\n• Di Depan Sawah',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openGoogleMaps(context);
            },
            icon: const Icon(Icons.map, color: Colors.black),
            label: const Text(
              'Buka Maps',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openGoogleMaps(BuildContext context) async {
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
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
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
          content: Text(
            'Tidak dapat membuka Google Maps. Pastikan aplikasi Maps terinstall.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}