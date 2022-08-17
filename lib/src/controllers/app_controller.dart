import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:clipboard/clipboard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/constants/constants.dart';
import 'package:gmaps_scraper_app/src/models/models.dart';
import 'package:gmaps_scraper_app/src/exceptions/exceptions.dart';
import 'package:gmaps_scraper_app/src/utils/utils.dart';

class AppController extends GetxController {
  late Database db;

  late String deviceId;
  late LicenseKey licenseKey;

  late SharedPreferences prefs;
  late PackageInfo packageInfo;

  final TextEditingController emailTextCtrl = TextEditingController();
  final TextEditingController licenseTextCtrl = TextEditingController();

  @override
  void onReady() async {
    super.onReady();

    int? errorCode;

    db = sqlite3.open(
      dbName,
      mode: OpenMode.readWrite,
    );

    try {
      final String? platformDeviceId = await PlatformDeviceId.getDeviceId;

      if (platformDeviceId == null) {
        throw Exception('Device ID is Null!');
      }

      deviceId = platformDeviceId.trim();
    } catch (e) {
      errorCode = ErrorCodes.initDeviceID;
    }

    try {
      prefs = await SharedPreferences.getInstance();
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      errorCode = ErrorCodes.initPackages;
    }

    try {
      // await prefs.clear();

      if (!prefs.containsKey(StorageKeys.maxResult)) {
        await prefs.setInt(StorageKeys.maxResult, 10000);
      }

      if (!prefs.containsKey(StorageKeys.timeout)) {
        await prefs.setInt(StorageKeys.timeout, 120);
      }
    } catch (e) {
      errorCode = ErrorCodes.initApp;
    }

    try {
      final String val2 = Kcrypto.encrypt(
        <String>[
          packageInfo.appName,
          'C1C34037-F172-D74B-B908-6CF3F839D67E',
          DateTime.now().add(30.days).toSQL(),
          'Toan Doan',
          'toandev.95@gmail.com',
        ].join('*'),
      );
      print(val2);
      print(
        <String>[
          packageInfo.appName,
          'C1C34037-F172-D74B-B908-6CF3F839D67E',
          DateTime.now().add(30.days).toSQL(),
          'Toan Doan',
          'toandev.95@gmail.com',
        ].join('*'),
      );

      if (!prefs.containsKey(StorageKeys.licenseKey)) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Chào Mừng'),
            content: const Text(
              'Cảm ơn bạn đã quan tâm tới sản phẩm của chúng tôi, để sử dụng bạn vui lòng nhập khóa bản quyền.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'.toUpperCase()),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        );

        final dynamic result = await Get.toNamed(RouteKeys.license);

        if (result != true) {
          throw NoLicenseKeyException();
        }
      } else {
        final String? val = prefs.getString(StorageKeys.licenseKey);

        if (val != null) {
          final LicenseKey license = LicenseKey.fromKey(val);

          emailTextCtrl.text = license.email;
          licenseTextCtrl.text = license.raw;

          if (license.expiresAt.difference(DateTime.now()).inSeconds < 0) {
            await Get.dialog(
              AlertDialog(
                content: const Text(
                  'Phần mềm hiện tại đã hết hạn sử dụng, vui lòng nhập khóa bản quyền mới hoặc liên hệ với nhân viên hỗ trợ của chúng tôi để được hướng dẫn thêm. Xin chân thành cảm ơn!',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Liên Hệ'),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            );

            final dynamic result = await Get.toNamed(RouteKeys.license);

            if (result != true) {
              throw NoLicenseKeyException();
            }
          } else if (license.productName != packageInfo.appName) {
            throw LicenseKeyException();
          } else {
            licenseKey = license;
          }
        } else {
          throw LicenseKeyException();
        }
      }
    } on LicenseKeyException {
      await prefs.remove(StorageKeys.licenseKey);

      errorCode = ErrorCodes.initLicense;
    } on NoLicenseKeyException {
      errorCode = ErrorCodes.initLicense;
    } catch (e) {
      errorCode = ErrorCodes.initLicense;
    }

    if (errorCode == null) {
      await Future.delayed(2.seconds);

      await Get.offNamed(RouteKeys.main);
    } else {
      Get.dialog(
        AlertDialog(
          title: Text('Sự Cố'.toUpperCase()),
          content: Text(
            'Phần mềm xãy ra sự cố, vui lòng thử tắt mở lại phần mềm.\nMã lỗi #$errorCode',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Liên Hệ'.toUpperCase()),
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

  void handleActivation() async {
    await EasyLoading.show(
      status: 'Đang kích hoạt ...',
      dismissOnTap: false,
    );

    await Future.delayed(1.seconds);

    // print(emailTextCtrl.text);
    // print(licenseTextCtrl.text);

    try {
      final String val = licenseTextCtrl.text;
      final LicenseKey license = LicenseKey.fromKey(val);

      if (license.deviceId != deviceId) {
        await EasyLoading.showInfo(
          'Khóa bản quyền không được cấp phép sử dụng trên thiết bị này!.',
        );
      } else if (license.email != emailTextCtrl.text) {
        await EasyLoading.showInfo(
          'Địa chỉ Email không khớp với khóa bản quyền!',
        );
      } else if (license.expiresAt.difference(DateTime.now()).inSeconds < 0) {
        await EasyLoading.showInfo('Khóa bản quyền đã hết hạn sử dụng!');
      } else {
        await prefs.setString(StorageKeys.licenseKey, val);

        await EasyLoading.showSuccess('Đã kích hoạt thành công!');

        licenseKey = LicenseKey.fromKey(val);

        // await Get.offNamed(RouteKeys.main);
        Get.back(
          result: true,
        );
      }
    } catch (e) {
      print(e);

      await EasyLoading.showError('Khóa bản quyền không hợp lệ.');
    }

    // await EasyLoading.dismiss();
  }

  void handleCopyDeviceId() async {
    await FlutterClipboard.copy(deviceId);

    await EasyLoading.showToast('Đã sao chép mã thiết bị.');
  }
}
