// lib/pages/user_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/order_controller.dart';
import '../utils/price_formatter.dart';
import 'package:intl/intl.dart';

class UserOrdersPage extends StatelessWidget {
  UserOrdersPage({super.key});

  final OrderController orderC = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Riwayat Pesanan',
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.primary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () => orderC.fetchOrders(),
          ),
        ],
      ),
      body: Obx(() {
        if (orderC.isLoading.value && orderC.orders.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (orderC.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pesanan',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yuk, pesan sekarang!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: orderC.fetchOrders,
          color: colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderC.orders.length,
            itemBuilder: (context, index) {
              final order = orderC.orders[index];

              return Card(
                color: colorScheme.surfaceContainerHighest,
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showOrderDetail(context, order),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: orderC
                                    .getStatusColor(order.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getStatusIcon(order.status),
                                color: orderC.getStatusColor(order.status),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order.id}',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy, HH:mm',
                                    ).format(order.createdAt),
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: orderC.getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                orderC.getStatusLabel(order.status),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Item count
                        Text(
                          '${order.items?.length ?? 0} item',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Rp ${PriceFormatter.format(order.totalPrice)}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.delivery_dining;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  void _showOrderDetail(BuildContext context, order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Detail Pesanan',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            Text(
              'Order #${order.id}',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Items
            Text(
              'Item Pesanan:',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (order.items != null)
              ...order.items!.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fastfood,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.menuName,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        'Rp ${PriceFormatter.format(item.menuPrice)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 20),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${PriceFormatter.format(order.totalPrice)}',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pembayaran: ${order.paymentMethod.toUpperCase()}',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: orderC.getStatusColor(order.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    color: orderC.getStatusColor(order.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${orderC.getStatusLabel(order.status)}',
                    style: TextStyle(
                      color: orderC.getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}