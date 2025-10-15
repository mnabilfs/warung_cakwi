// 🔹 NEW — halaman baru untuk menu mie ayam
import 'package:flutter/material.dart';
import 'detail_page.dart';

class MieAyamPage extends StatelessWidget {
  const MieAyamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {"name": "Mie Ayam Biasa", "price": 10000},
      {"name": "Mie Ayam Bakso", "price": 15000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Mie Ayam")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final item = menu[index];
          return Card(
            child: ListTile(
              title: Text(item["name"]),
              subtitle: Text("Rp ${item["price"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(
                      title: item["name"],
                      price: item["price"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
