import 'dart:io';

import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';
import 'package:google_maps_scraper_app/src/utils/utils.dart';

class ResultController extends GetxController {
  final AppController appController = Get.find<AppController>();

  final RxnString currLabel = RxnString();
  final RxnString currKeyword = RxnString();

  List<Result> get allResults =>
      appController.resultBox.values.map((dynamic v) => v as Result).toList();

  List<String?> get labels =>
      allResults.groupBy((e) => e.label).keys.map((String? e) => e).toList();

  List<String> get keywords =>
      allResults.groupBy((e) => e.keyword).keys.toList();

  List<Result> get results {
    final List<Result> _results = appController.resultBox.values
        .map((dynamic v) => v as Result)
        .where((Result r) =>
            currLabel.value != null ? r.label == currLabel.value : true)
        .where((Result r) =>
            currKeyword.value == null || r.keyword == currKeyword.value)
        .toList();

    _results.sort((a, b) => a.createdAt != null && b.createdAt != null
        ? a.createdAt!.compareTo(b.createdAt!)
        : 0);

    return _results;
  }

  void handleExport() async {
    if (results.isEmpty) {
      await EasyLoading.showToast('Không có dữ liệu để xuất.');

      return;
    }

    await EasyLoading.show(
      status: 'Đang chọn đường dẫn ...',
      dismissOnTap: false,
    );

    String? _saveFilePath;

    try {
      _saveFilePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Chọn file lưu',
        fileName: 'GMAPS_IDEX.VN.xlsx',
        lockParentWindow: true,
      );
    } catch (e) {
      _saveFilePath = null;
    }

    if (_saveFilePath != null) {
      await EasyLoading.show(
        status: 'Đang tổng hợp dữ liệu ...',
        dismissOnTap: false,
      );

      final Excel _excel = Excel.createExcel();

      const String _defaultSheetName = 'Sheet1';

      final String _sheetName = currKeyword.value ?? _defaultSheetName;
      final Sheet _sheet1 = _excel[_sheetName];

      _sheet1.appendRow(
        <String>[
          'Tên',
          'Tên khác',
          'Số sao',
          'Lượt đánh giá',
          'Phân loại',
          'Thuộc tính',
          'Địa chỉ',
          'Giờ mở cửa',
          'Địa chỉ Website',
          'Số điện thoại',
          'Hình ảnh',
        ],
      );

      for (Result r in results) {
        _sheet1.appendRow(<String>[
          r.title ?? '',
          r.subTitle ?? '',
          r.star != null ? r.star.toString() : '',
          r.totalReview != null ? r.totalReview.toString() : '',
          r.categoryName ?? '',
          (r.attributes ?? <String>[]).join(','),
          r.address ?? '',
          r.openHours ?? '',
          r.websiteUrl ?? '',
          r.phoneNumber ?? '',
          r.imageUrl ?? '',
        ]);
      }

      if (_excel.setDefaultSheet(_sheetName) &&
          _sheetName != _defaultSheetName) {
        _excel.delete(_defaultSheetName);
      }

      final List<int>? _bytes = _excel.save();

      if (_bytes != null) {
        final File _file = await File(_saveFilePath).create();

        await _file.writeAsBytes(_bytes);
      }

      await Future.delayed(2.seconds);
      await EasyLoading.showSuccess('Đã xuất thành công dữ liệu!');
    } else {
      await EasyLoading.dismiss();
    }
  }
}
