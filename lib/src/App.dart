import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/screens/screens.dart';

class GoogleMapsScraperApp extends GetWidget<AppController> {
  const GoogleMapsScraperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      initialRoute: RouteKeys.splash,
      initialBinding: BindingsBuilder.put(() => AppController()),
      getPages: <GetPage>[
        GetPage(
          name: RouteKeys.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: RouteKeys.main,
          page: () => const MainScreen(),
          bindings: <Bindings>[
            BindingsBuilder.put(() => ToolController()),
            BindingsBuilder.put(() => ResultController()),
            BindingsBuilder.put(() => SettingController()),
          ],
        ),
      ],
      builder: EasyLoading.init(
        builder: (BuildContext context, Widget? child) {
          EasyLoading.instance
            ..dismissOnTap = true
            ..displayDuration = 3.seconds
            ..maskType = EasyLoadingMaskType.black;

          return child!;
        },
      ),
      localizationsDelegates: const <LocalizationsDelegate>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
    );
  }
}
