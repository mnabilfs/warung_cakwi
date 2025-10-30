import 'package:get/get.dart';
import '../controller/location_controller.dart';

class LocationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(() => LocationController());
  }
}