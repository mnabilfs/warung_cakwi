import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final int price;

  const DetailPage({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: title,
              child: Icon(Icons.ramen_dining, size: 120, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 24)),
            Text("Rp $price",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Tambah ke Keranjang"),
            ),
          ],
        ),
      ),
    );
  }
}
