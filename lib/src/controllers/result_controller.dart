import 'dart:io';

import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';

class ResultController extends GetxController {
  final AppController appController = Get.find<AppController>();

  final RxnString currLabel = RxnString();
  final RxnString currKeyword = RxnString();

  final RxList<Result> results = RxList<Result>.empty();

  List<String?> get labels {
    final ResultSet _res = appController.db.select(
      'SELECT `label` FROM `results` GROUP BY `label`',
    );

    return _res
        // ignore: prefer_null_aware_operators
        .map((Row r) => r['label'] != null ? r['label'].toString() : null)
        .toList();
  }

  List<String> get keywords {
    final ResultSet _res = appController.db.select(
      'SELECT `keyword` FROM `results` GROUP BY `keyword`',
    );

    return _res.map((Row r) => r['keyword'].toString()).toList();
  }

  @override
  void onReady() {
    super.onReady();

    everAll(
      <RxInterface>[currLabel, currKeyword],
      (e) {
        final List<Result> _results = loadData(
          label: currLabel.value,
          keyword: currKeyword.value,
          limit: 500,
        );

        results.assignAll(_results);
      },
    );

    currLabel.value = null;
    currKeyword.value = null;
  }

  List<Result> loadData({
    String? label,
    String? keyword,
    int? limit,
  }) {
    String _sql = 'SELECT * FROM `results` WHERE `id` NOT NULL ';

    if (label != null) {
      _sql += 'AND `label` = "$label" ';
    } else {
      _sql += 'AND `label` IS NULL ';
    }

    if (keyword != null) {
      _sql += 'AND `keyword` = "$keyword" ';
    }

    _sql += 'ORDER BY created_at DESC ';

    if (limit != null) {
      _sql += 'LIMIT $limit';
    }

    // print(_sql);

    final ResultSet _res = appController.db.select(_sql);

    return _res.map((Row r) => Result.fromRow(r)).toList();
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

      final List<Result> _results = loadData(
        label: currLabel.value,
        keyword: currKeyword.value,
      );

      for (Result r in _results) {
        _sheet1.appendRow(<String>[
          r.title ?? '',
          r.subTitle ?? '',
          r.star != null ? r.star.toString() : '',
          r.totalReview != null ? r.totalReview.toString() : '',
          r.categoryName ?? '',
          (r.attributes ?? <String>[]).join(', '),
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
