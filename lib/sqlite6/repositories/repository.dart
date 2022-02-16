import 'package:sqflite/sqflite.dart';
import 'database_connection.dart';

class Repository {
  DatabaseConnection _databaseConnection;
  Repository() {
    _databaseConnection = DatabaseConnection();
  }
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _databaseConnection.setDatabase();
    return _database;
  }

  insertData(table, data) async {
    var connection = await database;
    return await connection.insert(table, data);
  }

  readData(table) async {
    var connection = await database;
    return await connection.query(table);
  }

  readDataOrder(table) async {
    var connection = await database;
    return await connection
        .rawQuery('SELECT * FROM "$table" WHERE pemakai_status<>"3" ORDER BY pemakai_id DESC');
  }

  readDataOrderkedua() async {
    var connection = await database;
    return await connection
        .rawQuery('SELECT count(*)jml FROM pemakaian WHERE pemakai_status=2');
  }
  readDataOrderketiga() async {
    var connection = await database;
    return await connection
        .rawQuery('SELECT count(*)jml FROM pemakaian WHERE pemakai_status=1');
  }

  readDataById(table, itemId) async {
    var connection = await database;
    return await connection
        .query(table, where: 'pemakai_id=?', whereArgs: [itemId]);
  }
  readDataByPemakaiId(table, itemId) async {
    var connection = await database;
    return await connection
        .query(table, where: 'pemakai_id=?', whereArgs: [itemId]);
  }

  getItembypemakaiId(table, itemId) async {
    var connection = await database;
    return await connection
        .query(table, where: 'pemakai_id=?', whereArgs: [itemId]);
  }

  updateData(table, data) async {
    var connection = await database;
    return await connection
        .update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  terupdateData(pemakai_id, lot_number) async {
    var connection = await database;
    return await connection.rawUpdate(
        'UPDATE pemakaian_item SET status = "4" WHERE  status = "1" AND pemakai_id <>$pemakai_id AND lot_number= "$lot_number"');
  }
  updateprosesdatanull(lot_number) async {
    var connection = await database;
    return await connection.rawUpdate(
        'SELECT * FROM pemakaian_item WHERE lot_number= "$lot_number" AND status = "1"');
  }
 updateprosessync() async {
    var connection = await database;
    return await connection.rawUpdate(
        'UPDATE pemakaian SET pemakai_status = "3" WHERE pemakai_status = "2"');
  }
  deleteData() async {
    var connection = await database;
    return await connection.rawDelete(
        "DELETE FROM pemakaian_item WHERE pemakai_id in (SELECT pemakai_id FROM pemakaian WHERE pemakai_status =1)");
  }

  deleteDataItem() async {
    var connection = await database;
    return await connection
        .rawDelete("DELETE FROM pemakaian WHERE pemakai_status=1");
  }

  deletePemakai_status(table, itemId) async {
    var connection = await database;
    return await connection
        .rawDelete("DELETE FROM $table WHERE pemakai_status = 1");
  }
}
