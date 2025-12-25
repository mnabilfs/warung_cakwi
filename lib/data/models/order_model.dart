// lib/data/models/order_model.dart
class OrderModel {
  final int? id;
  final String userId;
  final String userEmail;
  final int totalPrice;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel>? items;

  OrderModel({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.totalPrice,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      totalPrice: json['total_price'] as int,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['order_items'] != null
          ? (json['order_items'] as List)
                .map((item) => OrderItemModel.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_email': userEmail,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final int? menuId;
  final String menuName;
  final int menuPrice;
  final int quantity;

  OrderItemModel({
    this.id,
    required this.orderId,
    this.menuId,
    required this.menuName,
    required this.menuPrice,
    this.quantity = 1,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      menuId: json['menu_id'] as int?,
      menuName: json['menu_name'] as String,
      menuPrice: json['menu_price'] as int,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'menu_id': menuId,
      'menu_name': menuName,
      'menu_price': menuPrice,
      'quantity': quantity,
    };
  }
}