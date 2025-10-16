import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[700]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.restaurant, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Warung Cakwi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Makanan Enak, Harga Terjangkau',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.orange),
            title: const Text('Beranda'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: const Text('Lokasi Toko'),
            subtitle: const Text('Lihat lokasi warung kami'),
            onTap: () {
              Navigator.pop(context);
              _showLocationDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Hubungi Kami'),
            subtitle: const Text('0812-3456-7890'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Telepon: 0812-3456-7890')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: const Text('Jam Operasional'),
            subtitle: const Text('Setiap Hari: 08.00 - 21.00'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 10),
            Text('Lokasi Warung Cakwi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jl. Raya Gubeng No. 123\nSurabaya, Jawa Timur\n60281',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Text(
              'Dekat dengan:\n• Kampus ITS\n• Pasar Atom\n• Stasiun Gubeng',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Google Maps...')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.map),
            label: const Text('Buka Maps'),
          ),
        ],
      ),
    );
  }
}