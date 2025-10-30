import 'package:get/get.dart';
import '../controller/cartitem_controller.dart';
import '../../../../data/models/menu_item.dart';

class CartItemBindings extends Bindings {
  final MenuItem item;

  CartItemBindings({required this.item});

  @override
  void dependencies() {
    Get.lazyPut<CartItemController>(() => CartItemController(item: item));
  }
}