import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/bindings/WelcomeBindings.dart';
import 'package:gmaps_scraper_app/src/bindings/MainBindings.dart';
import 'package:gmaps_scraper_app/src/views/WelcomeScreen.dart';
import 'package:gmaps_scraper_app/src/views/MainScreen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: Colors.red,
        fontFamily: 'Source Code Pro',
        appBarTheme: AppBarTheme(
          elevation: 3.0,
        ),
      ),
      initialRoute: '@welcome',
      getPages: [
        GetPage(
          name: '@welcome',
          page: () => WelcomeScreen(),
          binding: WelcomeBindings(),
        ),
        GetPage(
          name: '@main',
          page: () => MainScreen(),
          binding: MainBindings(),
        ),
      ],
      builder: EasyLoading.init(),
    );
  }
}
