import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:sqflite_common/sqlite_api.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';

import 'package:gmaps_scraper_app/src/exceptions/LicenseKeyException.dart';
import 'package:gmaps_scraper_app/src/models/LicenseKey.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

class WelcomeController extends GetxController {
  final AesCrypt crypt = AesCrypt();

  final RxBool loading = false.obs;
  final RxString message = ''.obs;

  String? deviceId;

  DbService dbService;

  WelcomeController(this.dbService);

  Database get db => dbService.instance!;

  @override
  void onInit() async {
    super.onInit();

    loading(true);

    try {
      deviceId = await PlatformDeviceId.getDeviceId;

      message('Đang tải trình thu thập ...');
      await downloadChrome();

      message('Đang kiểm tra bản quyền ...');

      crypt.setPassword('1234qwer');
      crypt.setOverwriteMode(AesCryptOwMode.on);
      crypt.setUserData(
        createdBy: 'Toan Doan',
      );

      await crypt.encryptTextToFile(
        // '$deviceId|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|trial',
        '$deviceId|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|premium',
        'license.key',
      );

      final String _licenseText = await crypt.decryptTextFromFile(
        'license.key',
      );

      final LicenseKey _licenseKey = LicenseKey.fromString(_licenseText);

      if (_licenseKey.deviceId != deviceId) {
        throw LicenseKeyException(
          'Khóa bản quyền không thể dùng trên thiết bị này.',
        );
      }

      if (_licenseKey.expiryDate!.difference(DateTime.now()).inDays < 0) {
        throw LicenseKeyException(
          'Khóa bản quyền đã hết hạn, vui lòng gia hạn thêm.',
        );
      }

      await db.insert(
        'users',
        _licenseKey.toMapSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Timer.periodic(
        Duration(
          seconds: 1,
        ),
        (Timer timer) async {
          if (_licenseKey.type == LicenseKeyType.TRIAL) {
            if (timer.tick >= 10) {
              timer.cancel();

              Get.offAllNamed('@main');
            } else {
              message('Đợi ${10 - timer.tick} giây để mở phần mềm.');
            }
          }

          if (_licenseKey.type == LicenseKeyType.PREMIUM && timer.tick >= 2) {
            timer.cancel();

            Get.offAllNamed('@main');
          }
        },
      );

      await Future.delayed(
        Duration(
          seconds: _licenseKey.type == LicenseKeyType.TRIAL ? 10 : 2,
        ),
      );
    } on AesCryptDataException catch (e) {
      if (e.message.contains('Incorrect password')) {
        message('Không có quyền đọc khóa bản quyền!');
      }
    } on FileSystemException catch (e) {
      if (e.message.contains('Source file')) {
        message('Không tìm thấy file khóa bản quyền!');
      }
    } on LicenseKeyException catch (e) {
      message(e.message ?? 'Mã thiết bị không hợp lệ.');
    } on Exception catch (e) {
      print(e);

      message('Không thể mở phần mềm, vui lòng liên hệ hỗ trợ.');
    } finally {
      loading.value = false;
    }
  }

  void copy() async {
    try {
      await FlutterClipboard.copy(deviceId!);

      Get.rawSnackbar(
        message: 'Đã sao chép mã thiết bị!',
      );
    } catch (e) {
      await Get.dialog(
        AlertDialog(
          content: Text('Không thể sao chép mã thiết bị.'),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => exit(0),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}
