import 'package:get/get.dart';

import 'package:gmaps_scraper_app/src/controllers/MainController.dart';
import 'package:gmaps_scraper_app/src/controllers/HomeController.dart';
import 'package:gmaps_scraper_app/src/controllers/ResultController.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());

    Get.lazyPut(() => HomeController(Get.find<DbService>()));
    Get.lazyPut(() => ResultController(Get.find<DbService>()));
  }
}
