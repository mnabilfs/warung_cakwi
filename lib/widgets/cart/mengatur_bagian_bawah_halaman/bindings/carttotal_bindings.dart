import 'package:get/get.dart';
import '../controller/carttotal_controller.dart';

class CartTotalBindings extends Bindings {
  final int itemCount;
  final int totalPrice;

  CartTotalBindings({
    required this.itemCount,
    required this.totalPrice,
  });

  @override
  void dependencies() {
    Get.lazyPut<CartTotalController>(
      () => CartTotalController(
        itemCount: itemCount,
        totalPrice: totalPrice,
      ),
    );
  }
}