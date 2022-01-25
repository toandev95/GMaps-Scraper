import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:clipboard/clipboard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';
import 'package:google_maps_scraper_app/src/exceptions/exceptions.dart';
import 'package:google_maps_scraper_app/src/utils/utils.dart';

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

    try {
      // await prefs.clear();

      if (!prefs.containsKey(StorageKeys.maxResult)) {
        await prefs.setInt(StorageKeys.maxResult, 10000);
      }

      if (!prefs.containsKey(StorageKeys.timeout)) {
        await prefs.setInt(StorageKeys.timeout, 120);
      }
    } catch (e) {
      _errorCode = ErrorCodes.initApp;
    }

    try {
      final String _val2 = Kcrypto.encrypt(
        <String>[
          packageInfo.appName,
          '92C0E9B6-E02C-9B48-149C-82F76C5F8EC0',
          DateTime.now().add(30.days).toSQL(),
          'Toan Doan',
          'toandev.95@gmail.com',
        ].join('*'),
      );
      print(_val2);

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

        final dynamic _result = await Get.toNamed(RouteKeys.license);

        if (_result != true) {
          throw NoLicenseKeyException();
        }
      } else {
        final String? _val = prefs.getString(StorageKeys.licenseKey);

        if (_val != null) {
          final LicenseKey _license = LicenseKey.fromKey(_val);

          emailTextCtrl.text = _license.email;
          licenseTextCtrl.text = _license.raw;

          if (_license.expiresAt.difference(DateTime.now()).inSeconds < 0) {
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

            return Get.offNamed(RouteKeys.license);
          } else if (_license.productName != packageInfo.appName) {
            throw LicenseKeyException();
          } else {
            licenseKey = _license;
          }
        } else {
          throw LicenseKeyException();
        }
      }
    } on LicenseKeyException {
      await prefs.remove(StorageKeys.licenseKey);

      _errorCode = ErrorCodes.initLicense;
    } on NoLicenseKeyException {
      _errorCode = ErrorCodes.initLicense;
    } catch (e) {
      _errorCode = ErrorCodes.initLicense;
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
      final String _val = licenseTextCtrl.text;
      final LicenseKey _license = LicenseKey.fromKey(_val);

      if (_license.deviceId != deviceId) {
        await EasyLoading.showInfo(
          'Khóa bản quyền này không được cấp phép sử dụng trên thiết bị này!.',
        );
      } else if (_license.email != emailTextCtrl.text) {
        await EasyLoading.showInfo(
          'Địa chỉ Email không khớp với khóa bản quyền!',
        );
      } else if (_license.expiresAt.difference(DateTime.now()).inSeconds < 0) {
        await EasyLoading.showInfo('Khóa bản quyền đã hết hạn sử dụng!');
      } else {
        await prefs.setString(StorageKeys.licenseKey, _val);

        await EasyLoading.showSuccess('Đã kích hoạt thành công!');

        licenseKey = LicenseKey.fromKey(_val);

        // await Get.offNamed(RouteKeys.main);
        Get.back(
          result: true,
        );
      }
    } catch (e) {
      await EasyLoading.showError('Khóa bản quyền không hợp lệ.');
    }

    // await EasyLoading.dismiss();
  }

  void handleCopyDeviceId() async {
    await FlutterClipboard.copy(deviceId);

    await EasyLoading.showToast('Đã sao chép mã thiết bị.');
  }
}
