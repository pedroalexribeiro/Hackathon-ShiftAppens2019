import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:a_friendly_reminder/medicine.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
    return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "teste.db");
    // Load database from asset and copy
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
      ByteData data = await rootBundle.load(join('assets', 'aFriendlyReminder.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }
    return await openDatabase(path, version: 1, onOpen: (db) {});
  }

  Future<int> newMedicine(Medicine newMedicine, var time) async {
    final db = await database;
    //get the biggest id in the table
    //var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM user_medicines");
    //int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into user_medicines (id_medicine,id_user,start_time,interval)"
        " VALUES (?,?,?,?)",
        [newMedicine.id, 1, time.toString(), newMedicine.interval]);
    return raw;
  }

  updateMedicine(Medicine newMedicine) async {
    final db = await database;
    var res = await db.update("Client", newMedicine.toJson(),
        where: "id = ?", whereArgs: [newMedicine.id]);
    return res;
  }

  getMedicine(int id) async {
    final db = await database;
    var res = await db.query("Medicine", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Medicine.fromJson(res.first) : null;
  }

  Future<Medicine> getMedicineByName(String name) async{
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM medicine WHERE name LIKE '" + name + "%'");
    return res.isNotEmpty ? Medicine.fromJson(res.first) : null;
  }

  Future<List<Medicine>> getBlockedClients() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query("Client", where: "blocked = ? ", whereArgs: [1]);

    List<Medicine> list =
        res.isNotEmpty ? res.map((c) => Medicine.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Medicine>> getAllMedicine() async {
    final db = await database;
    var res = await db.rawQuery("SELECT medicine.* FROM medicine INNER JOIN user_medicines ON (medicine.id=user_medicines.id_medicine);");
    List<Medicine> list =
        res.isNotEmpty ? res.map((c) => Medicine.fromJson(c)).toList() : [];
    return list;
  }

  deleteMedicine(int id) async {
    final db = await database;
    return db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Client");
  }
}