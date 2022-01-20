import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait(
    <Future>[
      initializeDateFormatting('vi'),
      Hive.initFlutter(BoxKeys.path),
    ],
  );

  runApp(const GoogleMapsScraperApp());
}
