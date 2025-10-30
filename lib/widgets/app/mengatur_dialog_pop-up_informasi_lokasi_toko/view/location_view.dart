import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  static void show(BuildContext context) {
    Get.lazyPut<LocationController>(() => LocationController());
    
    showDialog(
      context: context,
      builder: (context) => const LocationView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 10),
          Text(controller.title, style: const TextStyle(color: Color(0xFFD4A017))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.address,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            controller.nearbyPlaces,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            controller.openGoogleMaps(context);
          },
          icon: const Icon(Icons.map, color: Colors.black),
          label: const Text('Buka Maps', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017)),
        ),
      ],
    );
  }
}