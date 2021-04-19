import 'package:get/get.dart';

import 'package:gmaps_scraper_app/src/controllers/WelcomeController.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

class WelcomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(WelcomeController(Get.find<DbService>()));
  }
}
