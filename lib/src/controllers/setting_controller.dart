import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';

class SettingController extends GetxController {
  final AppController appController = Get.find<AppController>();
  final ResultController resultController = Get.find<ResultController>();

  final TextEditingController chromePathTextCtrl = TextEditingController();
  final TextEditingController maxResultTextCtrl = TextEditingController();
  final TextEditingController timeoutTextCtrl = TextEditingController();
  final TextEditingController proxyTextCtrl = TextEditingController();

  SharedPreferences get prefs => appController.prefs;

  @override
  void onReady() async {
    super.onReady();

    if (prefs.containsKey(StorageKeys.chromePath)) {
      chromePathTextCtrl.text = prefs.getString(StorageKeys.chromePath) ?? '';
    }

    if (prefs.containsKey(StorageKeys.maxResult)) {
      maxResultTextCtrl.text =
          (prefs.getInt(StorageKeys.maxResult) ?? 0).toString();
    }

    if (prefs.containsKey(StorageKeys.timeout)) {
      timeoutTextCtrl.text =
          (prefs.getInt(StorageKeys.timeout) ?? 0).toString();
    }

    if (prefs.containsKey(StorageKeys.proxy)) {
      proxyTextCtrl.text = prefs.getString(StorageKeys.proxy) ?? '';
    }
  }

  void handleSave() async {
    final String _chromePath = chromePathTextCtrl.text;
    final int? _maxResult = int.tryParse(maxResultTextCtrl.text);
    final int? _timeout = int.tryParse(timeoutTextCtrl.text);
    final String _proxy = proxyTextCtrl.text;

    if (!File(_chromePath).existsSync()) {
      await EasyLoading.showToast('Đường dẫn Chrome không hợp lệ.');
    } else if (_maxResult == null || _maxResult < 10) {
      await EasyLoading.showToast('Thông số kết quả tối đa không hợp lệ.');
    } else if (_timeout == null || _timeout < 30) {
      await EasyLoading.showToast('Thông số thời gian hết hạn không hợp lệ.');
    } else {
      await Future.wait(
        <Future>[
          prefs.setString(StorageKeys.chromePath, _chromePath),
          prefs.setInt(StorageKeys.maxResult, _maxResult),
          prefs.setInt(StorageKeys.timeout, _timeout),
          prefs.setString(StorageKeys.proxy, _proxy),
        ],
      );

      await EasyLoading.showSuccess('Đã lưu thông tin cấu hình!');
    }
  }

  void handleReset() async {
    final dynamic _result = await Get.dialog(
      AlertDialog(
        content: const Text('Bạn có chắc muốn xóa toàn bộ dữ liệu.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Không'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: const Text('Có'),
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
      await EasyLoading.show(
        status: 'Đang xóa dữ liệu ...',
        dismissOnTap: false,
      );

      appController.db
          .prepare('DELETE FROM `results` WHERE `id` != 0')
          .execute();

      resultController.currLabel.value = null;
      resultController.currKeyword.value = null;

      await EasyLoading.showSuccess('Đã xóa dữ liệu thành công!');
    }
  }
}
