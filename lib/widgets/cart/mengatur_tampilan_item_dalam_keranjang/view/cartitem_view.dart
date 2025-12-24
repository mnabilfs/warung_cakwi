import 'package:flutter/material.dart';
import '../../../../data/models/menu_item.dart';
import '../../../../utils/price_formatter.dart';

// 🔍 MARKER: AESTHETIC_MINIMALIST_CART_ITEM
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
        ),
      ),
    );
  }

  Widget _buildLeadingImage(ColorScheme colorScheme) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: 96,
            cacheHeight: 96,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(colorScheme);
            },
          ),
        ),
      );
    }
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
