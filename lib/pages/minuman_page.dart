// 🔹 NEW — halaman baru untuk menu minuman
import 'package:flutter/material.dart';
import 'detail_page.dart';

class MinumanPage extends StatelessWidget {
  const MinumanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {"name": "Es Teh", "price": 5000},
      {"name": "Es Jeruk", "price": 5000},
      {"name": "Es Sogem", "price": 10000},
      {"name": "Kopi", "price": 5000},
      {"name": "Teh Hangat", "price": 4000},
      {"name": "Jeruk Hangat", "price": 4000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Minuman")),
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
