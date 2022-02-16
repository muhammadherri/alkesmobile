class Pemakaian{
  int id;
  int pemakai_id;
  String pemakai_no;
  String pemakai_date;
  String pemakai_cabang;
  String pemakai_rs;
  String pinjam_by;
  String pemakai_dokter;
  String pinjam_date;
  String pemakai_by;
  int pemakai_status;
  String pemakai_paket;
  String created_at;
  String updated_at;
  String pemakai_bast;
  String paket_name;
  String status_description;
  String teknisi;

  pemakaianMap(){
    var mapping = Map<String, dynamic>();
    mapping['id']=id;
    mapping['pemakai_id']=pemakai_id;
    mapping['pemakai_no']=pemakai_no;
    mapping['pemakai_date']=pemakai_date;
    mapping['pemakai_cabang']=pemakai_cabang;
    mapping['pemakai_rs']=pemakai_rs;
    mapping['pinjam_by']=pinjam_by;
    mapping['pemakai_dokter']=pemakai_dokter;
    mapping['pinjam_date']=pinjam_date;
    mapping['pemakai_by']=pemakai_by;
    mapping['pemakai_status']=pemakai_status;
    mapping['pemakai_paket']=pemakai_paket;
    mapping['created_at']=created_at;
    mapping['updated_at']=updated_at;
    mapping['pemakai_bast']=pemakai_bast;
    mapping['paket_name']=paket_name;
    mapping['status_description']=status_description;
    mapping['teknisi']=teknisi;


    return mapping;

  }
}