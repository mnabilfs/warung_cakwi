import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import View yang sudah miliki
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/network_location_view.dart';
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/gps_location_view.dart';
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/location_view.dart';

// Import Binding agar Controller otomatis jalan
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/bindings/location_binding.dart'; // Sesuaikan path jika berbeda
// Pastikan Anda membuat/mengimport file binding untuk Network & GPS juga jika ada di folder bindings
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/bindings/network_location_binding.dart'; 
import '../../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/bindings/gps_location_binding.dart';

class LocationSelectionPage extends StatelessWidget {
  const LocationSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil tema dari context agar konsisten dengan Dark/Light mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Metode Lokasi"),
        backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metode Pelacakan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih provider lokasi yang ingin Anda gunakan:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // 1. NETWORK LOCATION CARD
              _buildMenuCard(
                context: context,
                icon: Icons.network_cell,
                title: 'Network Location',
                subtitle: 'Hemat baterai, menggunakan Wi-Fi/Seluler.',
                color: Colors.blue,
                onTap: () {
                  // Navigasi ke Network View + Inisialisasi Binding
                  Get.to(
                    () => const NetworkLocationView(), 
                    binding: NetworkLocationBinding()
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. GPS LOCATION CARD
              _buildMenuCard(
                context: context,
                icon: Icons.gps_fixed,
                title: 'GPS Location',
                subtitle: 'Akurasi tinggi, menggunakan satelit GPS.',
                color: Colors.green,
                onTap: () {
                  // Navigasi ke GPS View + Inisialisasi Binding
                  Get.to(
                    () => const GpsLocationView(), 
                    binding: GpsLocationBinding()
                  );
                },
              ),

              const SizedBox(height: 16),

              // 3. LIVE TRACKER (Original)
              _buildMenuCard(
                context: context,
                icon: Icons.location_history,
                title: 'Live Tracker (Switch)',
                subtitle: 'Pelacak real-time dengan tombol switch.',
                color: Colors.orange,
                onTap: () {
                  // Navigasi ke Location View Original + Inisialisasi Binding
                  Get.to(
                    () => const LocationView(), 
                    binding: LocationBinding() // Binding asli (LocationBinding)
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}