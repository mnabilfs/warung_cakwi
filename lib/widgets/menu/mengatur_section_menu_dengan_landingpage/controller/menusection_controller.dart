import 'package:get/get.dart';
import '../../../../models/menu_item.dart';

class MenuSectionController extends GetxController {
  final String title;
  final List<MenuItem> items;
  final Function(MenuItem) onAddToCart;

  MenuSectionController({
    required this.title,
    required this.items,
    required this.onAddToCart,
  });
}