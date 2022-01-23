import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';
import 'package:google_maps_scraper_app/src/utils/utils.dart';
import 'package:google_maps_scraper_app/src/exceptions/exceptions.dart';

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

      if (prefs.containsKey(StorageKeys.timeout)) {
        await prefs.setInt(StorageKeys.timeout, 120);
      }
    } catch (e) {
      _errorCode = ErrorCodes.initApp;
    }

    try {
      if (!prefs.containsKey(StorageKeys.licenseKey)) {
        final dynamic _result = await Get.dialog(
          AlertDialog(
            title: const Text('Chào Mừng'),
            content: const Text(
              'Cảm ơn bạn đã cài đặt phần mềm, bạn sẽ được trải nghiệm miễn phí lần đầu trong vòng 24h. Chúc bạn một ngày làm việc hiệu quả.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Kích hoạt bản quyền'.toUpperCase()),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: Text('OK'.toUpperCase()),
                onPressed: () {
                  Get.back(
                    result: true,
                  );
                },
              ),
            ],
          ),
        );

        if (_result == true) {
          final String _val = Kcrypto.encrypt(
            <String>[
              deviceId,
              DateTime.now().add(1.days).toSQL(),
              // DateTime.now().toSQL(),
              'Free Trial',
              'support@idex.vn',
            ].join('*'),
          );
          // print(_val);

          // final String _val1 = Kcrypto.decrypt(_val);
          // print(_val1);

          await prefs.setString(StorageKeys.licenseKey, _val);

          licenseKey = LicenseKey.fromKey(Kcrypto.decrypt(_val));
        }
      } else {
        final String? _val = prefs.getString(StorageKeys.licenseKey);

        if (_val != null) {
          final LicenseKey _license = LicenseKey.fromKey(
            Kcrypto.decrypt(_val),
          );

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

            emailTextCtrl.text = _license.email;

            return Get.offNamed(RouteKeys.license);
          } else {
            licenseKey = _license;
          }
        } else {
          throw LicenseKeyException();
        }
      }
    } on LicenseKeyException {
      await prefs.remove(StorageKeys.licenseKey);

      rethrow;
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

    print(emailTextCtrl.text);
    print(licenseTextCtrl.text);

    await Future.delayed(2.seconds);

    await EasyLoading.dismiss();
  }
}
