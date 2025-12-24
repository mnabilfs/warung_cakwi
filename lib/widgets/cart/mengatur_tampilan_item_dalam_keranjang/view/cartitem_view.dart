import 'package:flutter/material.dart';
import '../../../../data/models/menu_item.dart';
import '../../../../utils/price_formatter.dart';

<<<<<<< HEAD
// 🔍 MARKER: AESTHETIC_MINIMALIST_CART_ITEM
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // ✅ AESTHETIC: Cleaner card design
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // ✅ AESTHETIC: Smaller image
            _buildLeadingImage(colorScheme),
            const SizedBox(width: 12),
            
            // ✅ AESTHETIC: Compact text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${PriceFormatter.format(item.price)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // ✅ AESTHETIC: Subtle delete button
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: colorScheme.error.withOpacity(0.7),
                size: 22,
              ),
              onPressed: onRemove,
              tooltip: 'Hapus',
            ),
          ],
=======
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
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildLeadingImage(ColorScheme colorScheme) {
=======
  // ✅ Build leading image dengan network image support
  Widget _buildLeadingImage() {
    // Jika ada imageUrl, tampilkan gambar dari network
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
<<<<<<< HEAD
          width: 48,
          height: 48,
          child: Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: 96,
            cacheHeight: 96,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(colorScheme);
=======
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
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
            },
          ),
        ),
      );
    }
<<<<<<< HEAD
    return _buildFallbackIcon(colorScheme);
  }

  Widget _buildFallbackIcon(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        item.icon ?? Icons.fastfood,
        color: colorScheme.primary,
        size: 24,
      ),
    );
  }
}
=======

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
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
