import 'package:get/get.dart';
import '../controller/whatsapp_controller.dart';

class WhatsAppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WhatsAppController>(() => WhatsAppController());
  }
}
