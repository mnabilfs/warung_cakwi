import 'package:get/get.dart';
import '../controller/menucard_controller.dart';
import '../../../../data/models/menu_item.dart';

class MenuCardBindings extends Bindings {
  final MenuItem item;

  MenuCardBindings({required this.item});

  @override
  void dependencies() {
    Get.lazyPut<MenuCardController>(() => MenuCardController(item: item));
  }
}