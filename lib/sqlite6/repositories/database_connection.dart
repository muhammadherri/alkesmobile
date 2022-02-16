import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseConnection {
 
  setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'dbalkes');
    print('db location : '+path);
    var database =
        await openDatabase(path, version: 1, onCreate: _onCreatingDatabase);
    return database;
  }

  _onCreatingDatabase(Database database, int version) async {
    await database.execute('''CREATE TABLE pemakaian_item(
          id INTEGER PRIMARY KEY,
          pemakai_id INTEGER,
          item_number TEXT,
          pemakai_date TEXT,
          lot_number TEXT,
          status INTEGER,
          item_desc TEXT,
          item_satuan TEXT,
          stock TEXT,
          status_desc TEXT
          )''');
          await database.execute('''CREATE TABLE pemakaian(
          id INTEGER PRIMARY KEY,
          pemakai_id INTEGER,
          pemakai_no TEXT,
          pemakai_date TEXT,
          pemakai_cabang TEXT,
          pemakai_rs TEXT,
          pinjam_by TEXT,
          pemakai_dokter TEXT,
          pinjam_date TEXT,
          pemakai_by TEXT,
          pemakai_status INTEGER,
          pemakai_paket TEXT,
          created_at TEXT,
          updated_at TEXT,
          pemakai_bast TEXT,
          paket_name TEXT,
          status_description TEXT,
          teknisi TEXT
          )''');
    
  }
}
