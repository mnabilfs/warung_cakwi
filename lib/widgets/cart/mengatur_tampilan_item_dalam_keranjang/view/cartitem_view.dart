import 'package:flutter/material.dart';
import '../../../../data/models/menu_item.dart';
import '../../../../utils/price_formatter.dart';

class CartItemView extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onRemove;

  const CartItemView({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // ✅ Tampilkan gambar dari network atau fallback ke icon
        leading: _buildLeadingImage(),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Rp ${PriceFormatter.format(item.price)}',
          style: const TextStyle(
            color: Color(0xFFD4A017),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }

  // ✅ Build leading image dengan network image support
  Widget _buildLeadingImage() {
    // Jika ada imageUrl, tampilkan gambar dari network
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: 120,
            cacheHeight: 120,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              
              return Container(
                color: const Color(0xFF3D3D3D),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: const Color(0xFFD4A017),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Fallback ke icon jika gambar gagal load
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon ?? Icons.fastfood,
                  color: const Color(0xFFD4A017),
                  size: 30,
                ),
              );
            },
          ),
        ),
      );
    }

    // Fallback ke CircleAvatar dengan icon jika tidak ada imageUrl
    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFF3D3D3D),
      child: Icon(
        item.icon ?? Icons.fastfood,
        color: const Color(0xFFD4A017),
        size: 30,
      ),
    );
  }
}