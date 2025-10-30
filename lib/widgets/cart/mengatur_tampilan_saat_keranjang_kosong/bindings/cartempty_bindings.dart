import 'package:get/get.dart';
import '../controller/cartempty_controller.dart';

class CartEmptyBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartEmptyController>(() => CartEmptyController());
  }
}