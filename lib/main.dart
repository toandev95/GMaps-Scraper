import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gmaps_scraper_app/src/App.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  await initServices();
  await initializeDateFormatting();

  runApp(MyApp());
}

Future<void> initServices() async {
  await Get.putAsync(() => DbService().init());
}
