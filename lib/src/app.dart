import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        GetPage(
          name: RouteKeys.license,
          page: () => const LicenseScreen(),
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
