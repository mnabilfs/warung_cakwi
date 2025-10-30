import 'package:get/get.dart';
import '../controller/menudetail_controller.dart';
import '../../../../models/menu_item.dart';

class MenuDetailBindings extends Bindings {
  final MenuItem menuItem;

  MenuDetailBindings({required this.menuItem});

  @override
  void dependencies() {
    Get.lazyPut<MenuDetailController>(
      () => MenuDetailController(menuItem: menuItem),
    );
  }
}