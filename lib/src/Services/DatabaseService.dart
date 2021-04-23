import 'package:get/get.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService extends GetxService {
  Database? db;

  Future<DatabaseService> init() async {
    db = await databaseFactoryFfi.openDatabase('gmaps.sqlite3');
    return this;
  }
}
