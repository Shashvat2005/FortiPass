import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._(); // Private constructor to prevent instantiation

  static final DbHelper getInstance =
      DbHelper._(); // Return the singleton instance

  static final String users = 'users'; // Table name
  static const String S_no = 'S_no'; // Column name
  static final String users_username = 'username'; // Column name
  static final String users_password = 'password'; // Column name
  static final String users_title_data = 'title'; // Column name
  static final String users_username_data = 'username_data'; // Column name
  static final String users_password_data = 'password_data'; // Column name
  static final String users_category_data = 'category_data'; // Column name
  static final String users_note_data = 'note_data'; // Column name
  static final String users_date_data = 'date_data'; // Column name
  static final String users_secure_data = 'secure_data';

  Database? myDB; // Database instance

  // DB Open (if opened) or create (if not opened)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  // Open the database and create the database if it doesn't exist
  Future<Database> openDB() async {
    Directory appPath = await getApplicationDocumentsDirectory();

    String dbPath = join(appPath.path, 'password_manager.db');

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        // Create the table
        db.execute('''
          CREATE TABLE $users (
            $S_no INTEGER PRIMARY KEY AUTOINCREMENT,
            $users_title_data TEXT NOT NULL,
            $users_username_data TEXT NOT NULL,
            $users_password_data TEXT NOT NULL,
            $users_category_data TEXT NOT NULL,
            $users_note_data TEXT NOT NULL,
            $users_secure_data INTEGER NOT NULL,
            $users_date_data DATE NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  // Insert data into the table
  Future<bool> addData(
      {required String title,
      required String username,
      required String password,
      required String category,
      required String note,
      required int secure,
      required String date}) async {
    Database db = await getDB();

    int rowsAffectecd = await db.insert(users, {
      users_title_data: title,
      users_username_data: username,
      users_password_data: password,
      users_category_data: category,
      users_note_data: note,
      users_secure_data: secure,
      users_date_data: date
    });

    return rowsAffectecd > 0;
  }

  // Return data in the table
  Future<List<Map<String, dynamic>>> getAllData() async {
    var db = await getDB();

    List<Map<String, dynamic>> mData = await db.query(users);

    return mData;
  }

  Future<List<Map<String, dynamic>>> getSecureData() async {
    var db = await getDB();

    List<Map<String, dynamic>> mData = await db.query(users,
        where: '$users_secure_data = ?',
        whereArgs: [1]); // 1 for secure data

    return mData;
  }

  Future<List<Map<String, dynamic>>> getUnsecureData() async {
    var db = await getDB();

    List<Map<String, dynamic>> mData = await db.query(users,
        where: '$users_secure_data = ?',
        whereArgs: [0]); // 0 for unsecure data

    return mData;
  }

  // Update data in the table
  Future<bool> updateData(
      {required String title,
      required String username,
      required String password,
      required String category,
      required String note,
      required int secure,
      required int id,
      required String date}) async {
    var db = await getDB();
    int rowsAffected = await db.update(
        users,
        {
          users_title_data: title,
          users_username_data: username,
          users_password_data: password,
          users_category_data: category,
          users_note_data: note,
          users_secure_data: secure,
          users_date_data: date
        },
        where: '$S_no = ?',
        whereArgs: [id]);

    return rowsAffected > 0;
  }

  Future<bool> updateSecureData(
      {required int secure, required int id}) async {
    var db = await getDB();
    int rowsAffected = await db.update(users,
        {users_secure_data: secure}, where: '$S_no = ?', whereArgs: [id]);

    return rowsAffected > 0;
  }
  // Delete data in the table
  Future<bool> deleteData(int id) async {
    var db = await getDB();

    int rowsAffected =
        await db.delete(users, where: '$S_no = ?', whereArgs: [id]);

    return rowsAffected > 0;
  }
}
