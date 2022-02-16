import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/repositories/repository.dart';

class Pemakaian_Item_Service {
  Repository _repository;
  Pemakaian_Item_Service() {
    _repository = Repository();
  }
  savePemakaian(Pemakaian pemakaian) async {
    return await _repository.insertData('pemakaian', pemakaian.pemakaianMap());
  }

  readPemakai() async {
    return await _repository.readDataOrder('pemakaian');
  }
  readPemakaikedua() async {
    return await _repository.readDataOrderkedua();
  }
 readPemakaiketiga() async {
    return await _repository.readDataOrderketiga();
  }
  // ignore: non_constant_identifier_names
  readPemakayById(pemakai_ID) async {
    return _repository.readDataById('pemakaian', pemakai_ID);
  }

  updatePemakaian(Pemakaian pemakaian) async {
    return await _repository.updateData('pemakaian', pemakaian.pemakaianMap());
  }
  deletePemakai_status() async {
    return await _repository.deleteData();
  }
 updatesync() async {
    return await _repository.updateprosessync();
  }
  save_Pemakaian_Item(Pemakaian_item pemakaian_item) async {
    return await _repository.insertData(
        'pemakaian_item', pemakaian_item.pemakaian_itemMap());
  }

  read_Pemakaian_Item() async {
    return await _repository.readDataOrder('pemakaian_item');
  }

  read_Pemakaian_ItemByID(pemakaian_id) async {
    return await _repository.readDataById('pemakaian_item', pemakaian_id);
  }

  read_Pemakaian_ItemByPemakaiID(pemakaian_id) async {
    return await _repository.readDataByPemakaiId(
        'pemakaian_item', pemakaian_id);
  }

  read_getPemakaian_ItemByPemakaiID(pemakaian_id) async {
    return await _repository.getItembypemakaiId('pemakaian_item', pemakaian_id);
  }
  update_Pemakaian_Item(Pemakaian_item pemakaian_item) async {
    return await _repository.updateData(
        'pemakaian_item', pemakaian_item.pemakaian_itemMap());
  }

  updateterpakai_Pemakaian_Item(pemakai_id, lot_number) async {
    return await _repository.terupdateData(pemakai_id,lot_number);
  }

   updatenullterpakai_Pemakaian_Item(pemakai_id) async {
    return await _repository.updateprosesdatanull(pemakai_id);
  }

  Delete_Pemakaian_Item() async {
    return await _repository.deleteDataItem();
  }
}
