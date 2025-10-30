import 'package:get/get.dart';

class CartTotalController extends GetxController {
  final int itemCount;
  final int totalPrice;

  CartTotalController({
    required this.itemCount,
    required this.totalPrice,
  });

  bool get canCheckout => itemCount > 0;
}