import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:rome_bus/rome_bus.dart';

import 'package:gmaps_scraper_app/src/events/KeywordAddedEvent.dart';
import 'package:gmaps_scraper_app/src/models/City.dart';
import 'package:gmaps_scraper_app/src/models/Keyword.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

class ResultController extends GetxController {
  final RxBool exporting = false.obs;

  final RxString path = ''.obs;

  final RxList<City> cities = <City>[].obs;
  final RxList<Keyword> keywords = <Keyword>[].obs;

  Rx<City>? city;
  Rx<Keyword>? keyword;

  DbService dbService;

  ResultController(this.dbService);

  @override
  bool get initialized => super.initialized && keyword != null && city != null;

  Database get db => dbService.instance!;

  bool get lauched => super.initialized && exporting();

  @override
  void onInit() async {
    super.onInit();

    RomeBus.getBus().register<KeywordAddedEvent>(
      (dynamic e) => loadK(),
    );

    await Future.wait([
      loadK(),
      loadC(),
    ]);
  }

  Future<void> loadK() async {
    try {
      await db.query('keywords').then((List<Map<String, Object?>> _results) {
        keywords.clear();

        _results.forEach((Map<String, Object?> keyword) {
          keywords.add(
            Keyword(
              id: (keyword['id'] as int),
              name: (keyword['name'] as String),
            ),
          );
        });

        if (keywords().length > 0) {
          keyword = keywords().first.obs;
        }
      });
    } catch (e) {
      print(e);

      await Get.dialog(
        AlertDialog(
          content: Text('Sự cố phân tích cơ sở dữ liệu.'),
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

  Future<void> loadC() async {
    try {
      await db.query('cities').then((List<Map<String, Object?>> _results) {
        cities.clear();

        _results.forEach((Map<String, Object?> city) {
          cities.add(
            City(
              id: (city['id'] as int),
              name: (city['name'] as String),
            ),
          );
        });

        if (cities().length > 0) {
          city = cities().first.obs;
        } else {
          throw Error();
        }
      });
    } catch (e) {
      print(e);

      await Get.dialog(
        AlertDialog(
          content: Text('Sự cố phân tích cơ sở dữ liệu.'),
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

  void pick() async {
    final String _fileName = DateFormat('d-M-y').format(DateTime.now());
    final String? _path = await getSavePath(
      suggestedName: '$_fileName.xlsx',
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: ['xlsx'],
        ),
      ],
      confirmButtonText: 'Chọn',
    );

    path(_path != null ? _path : '');
  }

  void export() async {
    exporting(true);

    await EasyLoading.show(
      status: 'Đang xử lý xữ liệu ...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final List<Map<String, Object?>> _results = await db.rawQuery(
        '''
          SELECT r.*, k.name AS keyword_name, ct.name AS city_name, c.name AS category_name FROM results AS r
          LEFT JOIN keywords AS k ON r.keyword_id = k.id
          LEFT JOIN cities AS ct ON r.city_id = ct.id
          LEFT JOIN categories AS c ON r.category_id = c.id
          WHERE r.keyword_id = ? AND r.city_id = ?
          ORDER BY created_at DESC LIMIT 1000
        ''',
        [
          keyword!.value.id,
          city!.value.id,
        ],
      );

      final Excel _excel = Excel.createExcel();

      final Sheet _sheet = _excel['IDEX'];
      _excel.setDefaultSheet('IDEX');

      await Future.wait(
        _results.map((Map<String, Object?> result) async {
          final List<String> _editorials = await db.rawQuery(
            '''
            SELECT e.name as editorial_name FROM editorial_result AS er
            LEFT JOIN editorials AS e ON er.editorial_id = e.id
            WHERE er.result_id = ?
            ''',
            [
              (result['id'] as int),
            ],
          ).then(
            (List<Map<String, Object?>> results) => results
                .map((Map<String, Object?> e) => e['editorial_name'] as String)
                .toList(),
          );

          _sheet.appendRow(
            [
              result['keyword_name'],
              result['city_name'],
              result['category_name'],
              _editorials.join(', '),
              result['title'],
              result['image_url'],
              result['star'],
              result['review'],
              result['address'],
              result['phone'],
              result['hour'],
              result['created_at'],
            ].map((dynamic e) => e != 'NULL' ? e : '').toList(),
          );
        }),
      );

      await File(path()).writeAsBytes(_excel.encode()!);

      await Future.delayed(
        Duration(
          seconds: 1,
        ),
      );

      await EasyLoading.showSuccess('Đã xuất dữ liệu thành công.');
    } catch (e) {
      print(e);

      await EasyLoading.showError('Không thể xuất dữ liệu.');
    } finally {
      exporting(false);
    }
  }
}
