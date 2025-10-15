// 🔹 NEW — halaman baru untuk menu lain
import 'package:flutter/material.dart';
import 'detail_page.dart';

class MenuLainPage extends StatelessWidget {
  const MenuLainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {"name": "Cuanki", "price": 10000},
      {"name": "Siomay", "price": 10000},
      {"name": "Batagor", "price": 10000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Lain")),
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
