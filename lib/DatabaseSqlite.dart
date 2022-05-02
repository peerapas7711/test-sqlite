// ignore: file_names
// ignore_for_file: unnecessary_null_comparison

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  Database? _db;
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    print('------ databasePath ------');
    print(databasesPath);
    String path = join(databasesPath, 'product.db');
    print(path);

    // open the database
    Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db
          .execute('CREATE TABLE products (id INTEGER PRIMARY KEY, item TEXT, qty TEXT)');
    });
    return db;
  }
}
