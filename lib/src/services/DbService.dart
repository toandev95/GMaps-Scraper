import 'package:get/get.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbService extends GetxService {
  Database? instance;

  Future<DbService> init() async {
    final DatabaseFactory _databaseFactory = databaseFactoryFfi;
    instance = await _databaseFactory.openDatabase('db.sqlite3');

    return this;
  }
}
