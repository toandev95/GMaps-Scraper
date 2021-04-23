import 'package:get/get.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/Controllers/Controllers.dart';
import 'package:gmaps_scraper_app/src/Models/Models.dart';
import 'package:gmaps_scraper_app/src/Services/Services.dart';

class MainController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final DatabaseService databaseService = Get.find<DatabaseService>();

  final RxInt currentIndex = RxInt(0);

  final RxList<Province> listProvince = RxList<Province>.empty();

  User get currentUser => authController.currentUser.value!;

  Database get db => databaseService.db!;

  @override
  void onInit() async {
    await Future.wait([
      EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        status: 'Đang khởi tạo môi trường.',
      ),
      downloadChrome(),
      fechProvince(),
    ]);

    await EasyLoading.dismiss();

    super.onInit();
  }

  Future<void> fechProvince() async {
    await db.query('provinces').then(
      (List<Map<String, Object?>> results) {
        listProvince.addAll(results.map(Province.fromMap));
      },
    );
  }

  Future<void> fetchDistrict(int provinceId) async {
    final Province? item = listProvince.firstWhere(
      (Province p) => p.id == provinceId,
    );

    if (item != null && item.districts!.length == 0) {
      await Future.wait([
        EasyLoading.show(
          maskType: EasyLoadingMaskType.black,
          status: 'Đang truy xuất thông tin.',
        ),
        db.query(
          'districts',
          where: 'province_id = ?',
          whereArgs: [provinceId],
        ).then(
          (List<Map<String, Object?>> results) {
            item.districts!.addAll(results.map(District.fromMap));
          },
        ),
      ]);

      await EasyLoading.dismiss();
    }
  }

  void toTab(int index) {
    currentIndex.value = index;

    Get.back();
  }
}
