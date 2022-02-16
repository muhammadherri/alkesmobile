class Pemakaian_item {
  int id;
  int pemakai_id;
  String item_number;
  String pemakai_date;
  String lot_number;
  int status;
  String item_desc;
  String item_satuan;
  String stock;
  String status_desc;

  pemakaian_itemMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['pemakai_id'] = pemakai_id;
    mapping['item_number'] = item_number;
    mapping['pemakai_date'] = pemakai_date;
    mapping['lot_number'] = lot_number;
    mapping['status'] = status;

    mapping['item_desc'] = item_desc;
    mapping['item_satuan'] = item_satuan;
    mapping['stock'] = stock;
    mapping['status_desc'] = status_desc;

    return mapping;
  }
}
