import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/Controllers/Controllers.dart';
import 'package:gmaps_scraper_app/src/UI/UI.dart';

class GMapsApp extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        fontFamily: 'Roboto Mono',
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.blueGrey[50],
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      initialRoute: '@welcome',
      getPages: [
        GetPage(
          name: '@welcome',
          page: () => WelcomeScreen(),
        ),
        GetPage(
          name: '@main',
          page: () => MainScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => MainController());
            Get.lazyPut(() => ScraperController());
          }),
        ),
      ],
      onInit: () {
        Intl.defaultLocale = 'vi';
      },
      builder: EasyLoading.init(),
    );
  }
}
