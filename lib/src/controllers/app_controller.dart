import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';

class AppController extends GetxController {
  late Database db;

  late String deviceId;

  late SharedPreferences prefs;
  late PackageInfo packageInfo;

  @override
  void onReady() async {
    super.onReady();

    int? _errorCode;

    db = sqlite3.open(
      dbName,
      mode: OpenMode.readWrite,
    );

    try {
      final String? _deviceId = await PlatformDeviceId.getDeviceId;

      if (_deviceId == null) {
        throw Exception('Device ID is Null!');
      }

      deviceId = _deviceId;
    } catch (e) {
      _errorCode = ErrorCodes.initDeviceID;
    }

    try {
      prefs = await SharedPreferences.getInstance();
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      _errorCode = ErrorCodes.initPackages;
    }

    if (_errorCode == null) {
      await Future.delayed(2.seconds);

      await Get.offNamed(RouteKeys.main);
    } else {
      Get.dialog(
        AlertDialog(
          title: Text('Sự Cố'.toUpperCase()),
          content: Text(
            'Phần mềm xãy ra sự cố, vui lòng thử tắt mở lại phần mềm.\nMã lỗi #$_errorCode',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Gửi Báo Cáo'.toUpperCase()),
              onPressed: () {
                Get.back();

                exit(0);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Get.back();

                exit(0);
              },
            ),
          ],
        ),
      );
    }
  }
}
