import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/screens/WelcomeScreen.dart';
import 'package:gmaps_scraper_app/src/screens/MainScreen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        fontFamily: 'Source Code Pro',
      ),
      initialRoute: '@welcome',
      getPages: [
        GetPage(
          name: '@welcome',
          page: () => WelcomeScreen(),
        ),
        GetPage(
          name: '@main',
          page: () => MainScreen(),
        ),
      ],
      builder: EasyLoading.init(),
    );
  }
}
