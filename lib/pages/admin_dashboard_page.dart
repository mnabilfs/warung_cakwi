import 'dart:io';
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminC.menuItems.length,
          itemBuilder: (context, index) {
            final item = adminC.menuItems[index];

            return Card(
              color: const Color(0xFF2D2D2D),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                title: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Rp ${PriceFormatter.format(item.price)}',
                  style: const TextStyle(color: Color(0xFFD4A017)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(item.id!, item.imageUrl),
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

    adminC.clearSelectedImage();

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
              const SizedBox(height: 16),

              const Text(
                'Foto Menu (Opsional)',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),

              Obx(() {
                if (adminC.selectedImagePath.value != null) {
                  return SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: Image.file(
                              File(adminC.selectedImagePath.value!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () => adminC.clearSelectedImage(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.white30),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada gambar',
                          style: TextStyle(color: Colors.white30),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => adminC.pickImageFromGallery(),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Color(0xFFD4A017),
                      ),
                      label: const Text(
                        'Galeri',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4A017)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => adminC.pickImageFromCamera(),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFD4A017),
                      ),
                      label: const Text(
                        'Kamera',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4A017)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              adminC.clearSelectedImage();
              Get.back();
            },
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
                imageFile: adminC.selectedImageFile.value,
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

  // Reset selected image
  adminC.clearSelectedImage();

  Get.dialog(
    AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Text(
        'Edit Menu',
        style: TextStyle(color: Color(0xFFD4A017)),
      ),
      content: ConstrainedBox(
        // ✅ Beri constraint jelas untuk content
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),

              // Image Picker Section
              const Text(
                'Foto Menu',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // ✅ Image Preview dengan constraint yang jelas
              Obx(() {
                // Tampilkan gambar baru yang dipilih
                if (adminC.selectedImagePath.value != null) {
                  return _buildImagePreview(
                    child: Image.file(
                      File(adminC.selectedImagePath.value!),
                      fit: BoxFit.cover,
                    ),
                    onRemove: () => adminC.clearSelectedImage(),
                  );
                }

                // Tampilkan gambar existing jika ada
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
                  return _buildNetworkImagePreview(item.imageUrl!);
                }

                // Placeholder jika tidak ada gambar
                return _buildPlaceholder();
              }),

              const SizedBox(height: 12),

              // Tombol Pilih Gambar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => adminC.pickImageFromGallery(),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Color(0xFFD4A017),
                        size: 20,
                      ),
                      label: const Text(
                        'Galeri',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4A017)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => adminC.pickImageFromCamera(),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFD4A017),
                        size: 20,
                      ),
                      label: const Text(
                        'Kamera',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4A017)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            adminC.clearSelectedImage();
            Get.back();
          },
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

            final success = await adminC.updateMenuItem(
              id: item.id!,
              name: nameC.text,
              description: descC.text,
              price: int.parse(priceC.text),
              imageFile: adminC.selectedImageFile.value,
              existingImageUrl: item.imageUrl,
            );

            if (success) Get.back();
          },
          child: const Text('Update', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}

// ✅ Helper widget untuk image preview dengan constraint jelas
Widget _buildImagePreview({
  required Widget child,
  required VoidCallback onRemove,
}) {
  return SizedBox(
    width: double.infinity,
    height: 150,
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: double.infinity,
            height: 150,
            child: child,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.red, size: 20),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ✅ Helper widget untuk network image dengan loading state
Widget _buildNetworkImagePreview(String imageUrl) {
  return SizedBox(
    width: double.infinity,
    height: 150,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: 400,
        cacheHeight: 400,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Container(
            color: const Color(0xFF3D3D3D),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 3,
                  color: const Color(0xFFD4A017),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF3D3D3D),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.white30,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gagal memuat',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

// ✅ Helper widget untuk placeholder
Widget _buildPlaceholder() {
  return Container(
    width: double.infinity,
    height: 150,
    decoration: BoxDecoration(
      color: const Color(0xFF3D3D3D),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white30),
    ),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image, size: 40, color: Colors.white30),
          SizedBox(height: 8),
          Text(
            'Tidak ada gambar',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

  void _confirmDelete(int id, String? imageUrl) {
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
              final success = await adminC.deleteMenuItem(id, imageUrl);
              if (success) Get.back();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}