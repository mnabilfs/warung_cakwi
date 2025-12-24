import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_item.dart';
import '../services/fcm_service.dart';
import 'menu_controller.dart' as my; // ✅ Import MenuController

class AdminController extends GetxController {
  final _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final FcmService _fcmService = FcmService();
  var menuItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  var selectedImagePath = Rxn<String>();
  var selectedImageFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
  }

  // ✅ Helper method untuk refresh MenuController
  void _refreshMenuController() {
    if (Get.isRegistered<my.MenuController>()) {
      Get.find<my.MenuController>().fetchMenuItems();
      if (kDebugMode) print('✅ MenuController refreshed');
    }
  }

  // ✅ Helper method untuk send notification tanpa blocking UI
  void _sendNotificationAsync(Future<bool> Function() notificationCall) {
    // Fire and forget - don't await
    unawaited(
      notificationCall().catchError((e) {
        if (kDebugMode) print('⚠️ FCM notification error (non-blocking): $e');
        return false;
      }),
    );
  }

  /// Pilih gambar dari galeri
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImagePath.value = image.path;
        selectedImageFile.value = File(image.path);
        if (kDebugMode) print('✅ Image selected: ${image.path}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pilih gambar dari kamera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImagePath.value = image.path;
        selectedImageFile.value = File(image.path);
        if (kDebugMode) print('✅ Image captured: ${image.path}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error capturing image: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearSelectedImage() {
    selectedImagePath.value = null;
    selectedImageFile.value = null;
  }

  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      if (kDebugMode) print('📤 Uploading image: $fileName');
      
      final String path = 'menu_images/$fileName';
      
      await _supabase.storage.from('menu_images').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      final String publicUrl = _supabase.storage
          .from('menu_images')
          .getPublicUrl(path);
      
      if (kDebugMode) print('✅ Image uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      if (kDebugMode) print('❌ Upload error: $e');
      Get.snackbar(
        'Error',
        'Gagal upload gambar: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 5 && pathSegments[3] == 'menu_images') {
        final fileName = pathSegments.sublist(4).join('/');
        await _supabase.storage.from('menu_images').remove(['menu_images/$fileName']);
        if (kDebugMode) print('✅ Image deleted from storage');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Delete image error: $e');
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _supabase.from('menu_items').select().order('id');
      final List<MenuItem> data = (response as List<dynamic>)
          .map((item) => MenuItem.fromJson(item))
          .toList();
      
      menuItems.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) print('❌ Fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMenuItem({
    required String name,
    required String description,
    required int price,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      
      String? imageUrl;
      
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_')}.jpg';
        imageUrl = await uploadImage(imageFile, fileName);
        
        if (imageUrl == null) {
          throw Exception('Gagal upload gambar');
        }
      }
      
      await _supabase.from('menu_items').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      });
      
      clearSelectedImage();
      
      await fetchMenuItems();
      
      // ✅ Refresh MenuController setelah create
      _refreshMenuController();
      
      Get.snackbar(
        'Berhasil',
        'Menu berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // ✅ Send notification to users about new menu (fire-and-forget)
      _sendNotificationAsync(() => _fcmService.notifyMenuCreated(name));
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMenuItem({
    required int id,
    required String name,
    required String description,
    required int price,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      isLoading.value = true;
      
      String? imageUrl = existingImageUrl;
      
      if (imageFile != null) {
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await deleteImage(existingImageUrl);
        }
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_')}.jpg';
        imageUrl = await uploadImage(imageFile, fileName);
        
        if (imageUrl == null) {
          throw Exception('Gagal upload gambar');
        }
      }
      
      await _supabase.from('menu_items').update({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      }).eq('id', id);
      
      clearSelectedImage();
      
      await fetchMenuItems();
      
      // ✅ Refresh MenuController setelah update
      _refreshMenuController();
      
      Get.snackbar(
        'Berhasil',
        'Menu berhasil diupdate',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // ✅ Send notification to users about menu update (fire-and-forget)
      _sendNotificationAsync(() => _fcmService.notifyMenuUpdated(name));
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMenuItem(int id, String? imageUrl, {String? menuName}) async {
    try {
      isLoading.value = true;
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImage(imageUrl);
      }
      
      await _supabase.from('menu_items').delete().eq('id', id);
      
      await fetchMenuItems();
      
      // ✅ Refresh MenuController setelah delete
      _refreshMenuController();
      
      Get.snackbar(
        'Berhasil',
        'Menu berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // ✅ Send notification to users about menu deletion (fire-and-forget)
      if (menuName != null) {
        _sendNotificationAsync(() => _fcmService.notifyMenuDeleted(menuName));
      }
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}