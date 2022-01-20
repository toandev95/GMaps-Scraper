import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';

class AppController extends GetxController {
  late SharedPreferences prefs;
  late PackageInfo packageInfo;
  late Box resultBox;

  final RxnString deviceId = RxnString();

  @override
  void onInit() async {
    super.onInit();

    Hive.registerAdapter(ResultAdapter());
  }

  @override
  void onReady() async {
    super.onReady();

    int? _errorCode;

    resultBox = await Hive.openBox(BoxKeys.result);

    prefs = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();

    try {
      deviceId.value = await PlatformDeviceId.getDeviceId;
    } catch (e) {
      _errorCode = ErrorCodes.deviceIdNull;
    }

    if (_errorCode == null) {
      await Future.delayed(3.seconds);

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
