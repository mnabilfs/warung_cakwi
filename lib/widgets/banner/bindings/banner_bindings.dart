import 'package:get/get.dart';
import '../controller/banner_controller.dart';

class BannerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BannerController>(() => BannerController());
  }
}