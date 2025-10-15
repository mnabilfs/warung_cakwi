import 'package:flutter/material.dart';
import 'detail_page.dart';

class BaksoPage extends StatelessWidget {
  const BaksoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {"name": "Bakso Campur", "price": 10000},
      {"name": "Bakso Kasar Besar", "price": 5000},
      {"name": "Bakso Kasar Sedang", "price": 3000},
      {"name": "Bakso Halus Sedang", "price": 3000},
      {"name": "Bakso Krikil", "price": 1000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Bakso")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool wide = constraints.maxWidth > 600;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menu.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 2 : 1,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = menu[index];
              return ListTile(
                tileColor: Colors.orange.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(item["name"]!),
                subtitle: Text("Rp ${item["price"]}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        title: item["name"]!,
                        price: item["price"]!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
