import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:platform_device_id/platform_device_id.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';

import 'package:gmaps_scraper_app/src/exceptions/LicenseKeyException.dart';
import 'package:gmaps_scraper_app/src/models/LicenseKey.dart';

class WelcomeController extends GetxController {
  final AesCrypt crypt = AesCrypt();

  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  String? deviceId;

  @override
  void onInit() async {
    super.onInit();

    loading.value = true;

    try {
      deviceId = await PlatformDeviceId.getDeviceId;

      crypt.setPassword('1234qwer');

      // crypt.setOverwriteMode(AesCryptOwMode.on);
      // crypt.setUserData(
      //   createdBy: 'Toan Doan',
      // );
      // await crypt.encryptTextToFile(
      //   // 'Toàn Đoàn|toandev.95@gmail.com|$deviceId|2021-05-20',
      //   '1234!qwer',
      //   'license.key',
      // );

      final String _licenseText = await crypt.decryptTextFromFile(
        'license.key',
      );

      if (_licenseText != '1234!qwer') {
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
      }

      await Future.delayed(
        Duration(
          seconds: 2,
        ),
      );

      Get.offAllNamed('@main');
    } on AesCryptDataException catch (e) {
      if (e.message.contains('Incorrect password')) {
        error.value = 'Không có quyền đọc khóa bản quyền!';
      }
    } on FileSystemException catch (e) {
      if (e.message.contains('Source file')) {
        error.value = 'Không tìm thấy file khóa bản quyền!';
      }
    } on LicenseKeyException catch (e) {
      error.value = e.message ?? 'Mã thiết bị không hợp lệ.';
    } on Exception catch (e) {
      print(e);

      error.value = 'Không thể mở phần mềm, vui lòng liên hệ hỗ trợ.';
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
