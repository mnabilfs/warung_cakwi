import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/admin_controller.dart';
import '../data/controllers/auth_controller.dart';
import '../utils/price_formatter.dart';

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final AdminController adminC = Get.put(AdminController());
  final AuthController authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminC.fetchMenuItems(),
          ),
        ],
      ),
      body: Obx(() {
        if (adminC.isLoading.value && adminC.menuItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminC.errorMessage.isNotEmpty && adminC.menuItems.isEmpty) {
          return Center(
            child: Text(
              'Error: ${adminC.errorMessage}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // ✅ BAGIAN INI YANG DIUBAH
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminC.menuItems.length,
          itemBuilder: (context, index) {
            final item = adminC.menuItems[index];

            return Card(
              color: const Color(0xFF2D2D2D),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                // ✅ LEADING dengan GAMBAR
                leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Jika gambar gagal load, tampilkan icon
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D3D3D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fastfood,
                                color: Color(0xFFD4A017),
                              ),
                            );
                          },
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Color(0xFF3D3D3D),
                        child: Icon(Icons.fastfood, color: Color(0xFFD4A017)),
                      ),

                // ✅ TITLE
                title: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ✅ SUBTITLE
                subtitle: Text(
                  'Rp ${PriceFormatter.format(item.price)}',
                  style: const TextStyle(color: Color(0xFFD4A017)),
                ),

                // ✅ TRAILING (Tombol Edit & Delete)
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(item.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4A017),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: _showAddDialog,
      ),
    );
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final priceC = TextEditingController();
    final imageUrlC = TextEditingController(); // ✅ TAMBAH INI

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Tambah Menu',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ✅ TAMBAH FIELD IMAGE URL
              TextField(
                controller: imageUrlC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
            ),
            onPressed: () async {
              if (nameC.text.isEmpty || priceC.text.isEmpty) {
                Get.snackbar('Error', 'Nama dan harga wajib diisi');
                return;
              }

              final success = await adminC.createMenuItem(
                name: nameC.text,
                description: descC.text,
                price: int.parse(priceC.text),
                imageUrl: imageUrlC.text.isEmpty
                    ? null
                    : imageUrlC.text, // ✅ TAMBAH INI
              );

              if (success) Get.back();
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(item) {
    final nameC = TextEditingController(text: item.name);
    final descC = TextEditingController(text: item.description);
    final priceC = TextEditingController(text: item.price.toString());
    final imageUrlC = TextEditingController(
      text: item.imageUrl ?? '',
    ); // ✅ TAMBAH INI

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Edit Menu',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ✅ TAMBAH FIELD IMAGE URL
              TextField(
                controller: imageUrlC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
            ),
            onPressed: () async {
              final success = await adminC.updateMenuItem(
                id: item.id!,
                name: nameC.text,
                description: descC.text,
                price: int.parse(priceC.text),
                imageUrl: imageUrlC.text.isEmpty
                    ? null
                    : imageUrlC.text, // ✅ TAMBAH INI
              );

              if (success) Get.back();
            },
            child: const Text('Update', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        content: const Text(
          'Yakin ingin menghapus menu ini?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await adminC.deleteMenuItem(id);
              if (success) Get.back();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}