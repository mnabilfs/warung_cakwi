// lib/pages/admin_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/order_controller.dart';
import '../utils/price_formatter.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatelessWidget {
  AdminOrdersPage({super.key});

  final OrderController orderC = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Daftar Pesanan',
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
                  Icons.receipt_long,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pesanan',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
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
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: orderC.getStatusColor(order.status),
                    child: Icon(
                      Icons.receipt,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        order.userEmail,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(order.createdAt),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: orderC
                          .getStatusColor(order.status)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      orderC.getStatusLabel(order.status),
                      style: TextStyle(
                        color: orderC.getStatusColor(order.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Items
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
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      '• ${item.menuName}',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
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

                          // Total & Payment
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
                                style: textTheme.titleMedium?.copyWith(
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

                          // Status Actions
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (order.status == 'pending')
                                _buildActionButton(
                                  label: 'Konfirmasi',
                                  color: Colors.blue,
                                  onPressed: () => orderC.updateOrderStatus(
                                    order.id!,
                                    'confirmed',
                                  ),
                                ),
                              if (order.status == 'confirmed')
                                _buildActionButton(
                                  label: 'Proses',
                                  color: Colors.purple,
                                  onPressed: () => orderC.updateOrderStatus(
                                    order.id!,
                                    'preparing',
                                  ),
                                ),
                              if (order.status == 'preparing')
                                _buildActionButton(
                                  label: 'Siap',
                                  color: Colors.green,
                                  onPressed: () => orderC.updateOrderStatus(
                                    order.id!,
                                    'ready',
                                  ),
                                ),
                              if (order.status == 'ready')
                                _buildActionButton(
                                  label: 'Selesai',
                                  color: Colors.teal,
                                  onPressed: () => orderC.updateOrderStatus(
                                    order.id!,
                                    'completed',
                                  ),
                                ),
                              if (order.status != 'cancelled' &&
                                  order.status != 'completed')
                                _buildActionButton(
                                  label: 'Batalkan',
                                  color: Colors.red,
                                  onPressed: () => _confirmCancel(order.id!),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _confirmCancel(int orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              orderC.updateOrderStatus(orderId, 'cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}