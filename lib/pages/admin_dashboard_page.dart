// lib/pages/admin_dashboard_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/admin_controller.dart';
import '../data/controllers/auth_controller.dart';
import '../data/controllers/order_controller.dart'; // ✅ Import OrderController
import '../utils/price_formatter.dart';
import 'admin_orders_page.dart'; // ✅ Import AdminOrdersPage

// ✅ Helper function untuk close dialog dengan aman (avoid GetX snackbar bug)
void _closeDialog() {
  if (Get.isDialogOpen == true) {
    Navigator.of(Get.overlayContext!).pop();
  }
}

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final AdminController adminC = Get.put(AdminController());
  final AuthController authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.primary),
        actions: [
          // ✅ Tombol ke Admin Orders dengan badge
          Obx(() {
            final orderC = Get.find<OrderController>();
            final pendingCount = orderC.orders
                .where((o) => o.status == 'pending')
                .length;

            return IconButton(
              icon: Badge(
                label: Text('$pendingCount'),
                isLabelVisible: pendingCount > 0,
                child: Icon(Icons.receipt_long, color: colorScheme.primary),
              ),
              onPressed: () => Get.to(() => AdminOrdersPage()),
              tooltip: 'Daftar Pesanan',
            );
          }),

          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () => adminC.fetchMenuItems(),
          ),
        ],
      ),
      body: Obx(() {
        if (adminC.isLoading.value && adminC.menuItems.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (adminC.errorMessage.isNotEmpty && adminC.menuItems.isEmpty) {
          return Center(
            child: Text(
              'Error: ${adminC.errorMessage}',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminC.menuItems.length,
          itemBuilder: (context, index) {
            final item = adminC.menuItems[index];

            return Card(
              color: colorScheme.surfaceContainerHighest,
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
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.fastfood,
                                color: colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: colorScheme.surfaceContainerLow,
                        child: Icon(Icons.fastfood, color: colorScheme.primary),
                      ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Rp ${PriceFormatter.format(item.price)}',
                  style: TextStyle(color: colorScheme.primary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        item.id!,
                        item.imageUrl,
                        item.name,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final nameC = TextEditingController();
    final descC = TextEditingController();
    final priceC = TextEditingController();

    adminC.clearSelectedImage();

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Text(
          'Tambah Menu',
          style: TextStyle(color: colorScheme.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Nama Menu',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descC,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceC,
                style: TextStyle(color: colorScheme.onSurface),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Foto Menu (Opsional)',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
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
                            icon: Icon(Icons.close, color: Colors.red),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.surface,
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
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: colorScheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada gambar',
                          style: TextStyle(color: colorScheme.outline),
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
                      icon: Icon(
                        Icons.photo_library,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        'Galeri',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => adminC.pickImageFromCamera(),
                      icon: Icon(Icons.camera_alt, color: colorScheme.primary),
                      label: Text(
                        'Kamera',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
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
              _closeDialog();
            },
            child: Text(
              'Batal',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () async {
              if (nameC.text.isEmpty || priceC.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Nama dan harga wajib diisi',
                  backgroundColor: colorScheme.error,
                  colorText: colorScheme.onError,
                );
                return;
              }

              final success = await adminC.createMenuItem(
                name: nameC.text,
                description: descC.text,
                price: int.parse(priceC.text),
                imageFile: adminC.selectedImageFile.value,
              );

              if (success) _closeDialog();
            },
            child: Text(
              'Simpan',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, item) {
    final colorScheme = Theme.of(context).colorScheme;

    final nameC = TextEditingController(text: item.name);
    final descC = TextEditingController(text: item.description);
    final priceC = TextEditingController(text: item.price.toString());

    adminC.clearSelectedImage();

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Text('Edit Menu', style: TextStyle(color: colorScheme.primary)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameC,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Nama Menu',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descC,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceC,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Foto Menu',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                Obx(() {
                  if (adminC.selectedImagePath.value != null) {
                    return _buildImagePreview(
                      context: context,
                      child: Image.file(
                        File(adminC.selectedImagePath.value!),
                        fit: BoxFit.cover,
                      ),
                      onRemove: () => adminC.clearSelectedImage(),
                    );
                  }

                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
                    return _buildNetworkImagePreview(context, item.imageUrl!);
                  }

                  return _buildPlaceholder(context);
                }),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => adminC.pickImageFromGallery(),
                        icon: Icon(
                          Icons.photo_library,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Galeri',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
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
                        icon: Icon(
                          Icons.camera_alt,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Kamera',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
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
              _closeDialog();
            },
            child: Text(
              'Batal',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () async {
              if (nameC.text.isEmpty || priceC.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Nama dan harga wajib diisi',
                  backgroundColor: colorScheme.error,
                  colorText: colorScheme.onError,
                );
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

              if (success) _closeDialog();
            },
            child: Text(
              'Update',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview({
    required BuildContext context,
    required Widget child,
    required VoidCallback onRemove,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: double.infinity, height: 150, child: child),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: colorScheme.surface,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.close, color: colorScheme.error, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImagePreview(BuildContext context, String imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: colorScheme.surfaceContainerLow,
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
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.surfaceContainerLow,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image,
                      color: colorScheme.outline,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat',
                      style: TextStyle(
                        color: colorScheme.outline,
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

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, size: 40, color: colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int id,
    String? imageUrl,
    String menuName,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Text('Konfirmasi', style: TextStyle(color: colorScheme.primary)),
        content: Text(
          'Yakin ingin menghapus menu "$menuName"?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => _closeDialog(),
            child: Text(
              'Batal',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () async {
              final success = await adminC.deleteMenuItem(
                id,
                imageUrl,
                menuName: menuName,
              );
              if (success) _closeDialog();
            },
            child: Text('Hapus', style: TextStyle(color: colorScheme.onError)),
          ),
        ],
      ),
    );
  }
}