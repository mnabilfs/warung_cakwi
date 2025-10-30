import 'package:get/get.dart';
import '../controller/cartbutton_controller.dart';

class CartButtonBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartButtonController>(() => CartButtonController());
  }
}