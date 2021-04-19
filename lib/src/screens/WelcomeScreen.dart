import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:platform_device_id/platform_device_id.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';

import 'package:gmaps_scraper_app/src/models/LicenseKey.dart';
import 'package:gmaps_scraper_app/src/exceptions/LicenseKeyException.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AesCrypt _crypt = AesCrypt();

  String? _deviceId;

  String? _msg;

  @override
  void initState() {
    super.initState();

    _initScreen();
  }

  String get msg => _msg ?? '';

  set msg(String val) {
    setState(() {
      _msg = val;
    });
  }

  void _initScreen() async {
    _deviceId = await PlatformDeviceId.getDeviceId;

    msg = 'Đang kiểm tra tương thích hệ thống ...';

    await downloadChrome();

    try {
      _crypt.setPassword('1234qwer');

      // _crypt.setOverwriteMode(AesCryptOwMode.on);
      // _crypt.setUserData(
      //   createdBy: 'Toan Doan',
      // );
      // await _crypt.encryptTextToFile(
      //   // '$_deviceId|Toàn Đoàn|toandev.95@gmail.com|2021-07-20|trial',
      //   '$_deviceId|Toàn Đoàn|toandev.95@gmail.com|2021-08-20|premium',
      //   'license.key',
      // );

      final String _licenseText = await _crypt.decryptTextFromFile(
        'license.key',
      );
      final LicenseKey _lc = LicenseKey.fromString(_licenseText);

      if (_lc.deviceId != _deviceId) {
        throw LicenseKeyException(
          'Khóa bản quyền không thể dùng trên thiết bị này.',
        );
      }

      if (_lc.expiryDate!.difference(DateTime.now()).inDays < 0) {
        throw LicenseKeyException(
          'Khóa bản quyền đã hết hạn, vui lòng gia hạn thêm.',
        );
      }

      Timer.periodic(
        Duration(
          seconds: 1,
        ),
        (Timer timer) async {
          if (_lc.type == LicenseKeyType.TRIAL) {
            if (timer.tick >= 30) {
              timer.cancel();

              Get.offAllNamed('@main');
            } else {
              msg = 'Đợi ${30 - timer.tick} giây để mở phần mềm.';
            }
          }

          if (_lc.type == LicenseKeyType.PREMIUM) {
            if (timer.tick >= 2) {
              timer.cancel();

              Get.offAllNamed('@main');
            } else {
              msg = 'Hoàn tất, sẵn sàng sử dụng.';
            }
          }
        },
      );

      await Future.delayed(
        Duration(
          seconds: _lc.type == LicenseKeyType.TRIAL ? 30 : 2,
        ),
      );
    } on AesCryptDataException catch (e) {
      if (e.message.contains('Incorrect password')) {
        msg = 'Không có quyền đọc khóa bản quyền!';
      }
    } on FileSystemException catch (e) {
      if (e.message.contains('Source file')) {
        msg = 'Không tìm thấy file khóa bản quyền!';
      }
    } on LicenseKeyException catch (e) {
      msg = e.message ?? 'Mã thiết bị không hợp lệ.';
    } on Exception catch (e) {
      print(e);

      msg = 'Không thể mở phần mềm, vui lòng liên hệ hỗ trợ.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(
                    size: 120.0,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    'Công cụ thu thập dữ liệu Google Maps.'.toUpperCase(),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(msg),
            ),
          ],
        ),
      ),
    );
  }
}
