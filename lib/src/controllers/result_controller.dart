import 'dart:io';

import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/controllers/controllers.dart';
import 'package:gmaps_scraper_app/src/models/models.dart';

class ResultController extends GetxController {
  final AppController appController = Get.find<AppController>();

  final RxnString currLabel = RxnString();
  final RxnString currKeyword = RxnString();

  final RxList<Result> results = RxList<Result>.empty();

  List<String?> get labels {
    final ResultSet res = appController.db.select(
      'SELECT `label` FROM `results` GROUP BY `label`',
    );

    return res
        // ignore: prefer_null_aware_operators
        .map((Row r) => r['label'] != null ? r['label'].toString() : null)
        .toList();
  }

  List<String> get keywords {
    final ResultSet res = appController.db.select(
      'SELECT `keyword` FROM `results` GROUP BY `keyword`',
    );

    return res.map((Row r) => r['keyword'].toString()).toList();
  }

  @override
  void onReady() {
    super.onReady();

    everAll(
      <RxInterface>[currLabel, currKeyword],
      (e) {
        final List<Result> data = loadData(
          label: currLabel.value,
          keyword: currKeyword.value,
          limit: 500,
        );

        results.assignAll(data);
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
    String sql = 'SELECT * FROM `results` WHERE `id` NOT NULL ';

    if (label != null) {
      sql += 'AND `label` = "$label" ';
    } else {
      sql += 'AND `label` IS NULL ';
    }

    if (keyword != null) {
      sql += 'AND `keyword` = "$keyword" ';
    }

    sql += 'ORDER BY created_at DESC ';

    if (limit != null) {
      sql += 'LIMIT $limit';
    }

    // print(_sql);

    final ResultSet res = appController.db.select(sql);

    return res.map((Row r) => Result.fromRow(r)).toList();
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

    String? saveFilePath;

    try {
      saveFilePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Chọn file lưu',
        fileName: 'GMAPS_IDEX.VN.xlsx',
        lockParentWindow: true,
      );
    } catch (e) {
      saveFilePath = null;
    }

    if (saveFilePath != null) {
      await EasyLoading.show(
        status: 'Đang tổng hợp dữ liệu ...',
        dismissOnTap: false,
      );

      final Excel excel = Excel.createExcel();

      const String defaultSheetName = 'Sheet1';

      final String sheetName = currKeyword.value ?? defaultSheetName;
      final Sheet sheet1 = excel[sheetName];

      sheet1.appendRow(
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

      final List<Result> results = loadData(
        label: currLabel.value,
        keyword: currKeyword.value,
      );

      for (Result r in results) {
        sheet1.appendRow(<String>[
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

      if (excel.setDefaultSheet(sheetName) && sheetName != defaultSheetName) {
        excel.delete(defaultSheetName);
      }

      final List<int>? bytes = excel.save();

      if (bytes != null) {
        final File file = await File(saveFilePath).create();

        await file.writeAsBytes(bytes);
      }

      await Future.delayed(2.seconds);
      await EasyLoading.showSuccess('Đã xuất thành công dữ liệu!');
    } else {
      await EasyLoading.dismiss();
    }
  }
}
