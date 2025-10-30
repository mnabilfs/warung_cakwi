import 'package:get/get.dart';
import '../controller/drawerheader_controller.dart';

class DrawerHeaderBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrawerHeaderController>(() => DrawerHeaderController());
  }
}