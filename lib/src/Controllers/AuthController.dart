import 'dart:io';

import 'package:get/get.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'package:gmaps_scraper_app/src/Models/Models.dart';

class AuthController extends GetxController {
  final AesCrypt crypt = AesCrypt();

  final RxnString deviceId = RxnString();

  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() async {
    crypt.setPassword('Toan@ACN');
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setUserData(
      createdBy: 'Toan Doan',
    );

    deviceId.value = await PlatformDeviceId.getDeviceId;

    super.onInit();
  }

  @override
  void onReady() async {
    await fetchUser();

    if (currentUser.value != null) {
      if (currentUser.value!.trial!) {
        // await Future.delayed(
        //   Duration(
        //     seconds: 3,
        //   ),
        // );
      }

      Get.offAllNamed('@main');
    }

    super.onReady();
  }

  Future<void> fetchUser() async {
    await crypt.encryptTextToFile(
      '${deviceId.value}|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|trial',
      // '${deviceId.value}&&${deviceId.value}|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|trial',
      // '$deviceId|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|premium',
      'license.acn',
      bom: true,
      utf16: true,
    );

    try {
      final String _text = await crypt.decryptTextFromFile(
        'license.acn',
        utf16: true,
      );
      final List<String> _ls = _text.split('|');

      if (_ls.length != 5) {
        throw 'Mã bản quyền không hợp lệ.';
      }

      final User _user = User.fromArray(_ls);

      if (!_user.deviceIds!.contains(deviceId.value)) {
        throw 'Khóa bản quyền không thể dùng trên thiết bị này.';
      }

      if (_user.expiresAt!.difference(DateTime.now()).inDays < 0) {
        throw 'Khóa bản quyền đã hết hạn, vui lòng gia hạn thêm.';
      }

      currentUser.value = _user;
    } on FileSystemException {
      throw 'Không thể đọc khoá bản quyền.';
    }
  }
}
