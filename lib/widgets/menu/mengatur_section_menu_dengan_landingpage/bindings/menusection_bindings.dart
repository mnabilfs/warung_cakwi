import 'package:get/get.dart';
import '../controller/menusection_controller.dart';
import '../../../../models/menu_item.dart';

class MenuSectionBindings extends Bindings {
  final String title;
  final List<MenuItem> items;
  final Function(MenuItem) onAddToCart;

  MenuSectionBindings({
    required this.title,
    required this.items,
    required this.onAddToCart,
  });

  @override
  void dependencies() {
    Get.lazyPut<MenuSectionController>(
      () => MenuSectionController(
        title: title,
        items: items,
        onAddToCart: onAddToCart,
      ),
    );
  }
}