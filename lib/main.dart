import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmaps_scraper_app/src/Services/Services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gmaps_scraper_app/src/App.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  await initializeDateFormatting();
  await initServices();

  runApp(GMapsApp());
}

Future<void> initServices() async {
  await Get.putAsync<DatabaseService>(() => DatabaseService().init());
}
