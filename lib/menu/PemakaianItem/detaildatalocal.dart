import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:alkes/main.dart';
import 'package:alkes/menu/PemakaianItem/datalocal.dart';
import 'package:alkes/menu/PemakaianItem/detailTopup.dart';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailLocal extends StatefulWidget {
  final Pinjam;
  DetailLocal({
    this.Pinjam,
  });
  @override
  _DetailLocalState createState() => _DetailLocalState(
      pemakai_id: this.Pinjam.pemakai_id,
      pinjam_date: this.Pinjam.pinjam_date,
      pemakai_cabang: this.Pinjam.pemakai_cabang,
      pemakai_no: this.Pinjam.pemakai_no,
      pemakai_rs: this.Pinjam.pemakai_rs,
      pemakai_dokter: this.Pinjam.pemakai_dokter,
      pemakai_status: this.Pinjam.pemakai_status.toString(),
      paket_name: this.Pinjam.paket_name);
}

class _DetailLocalState extends State<DetailLocal> {
  var jml = TextEditingController();
  String jmlh;
  var _editpemakai_id = TextEditingController();
  var Pinjam;
  var _pinjam;
  var _edit_lot_numberCont = TextEditingController();
  var _teknisi = TextEditingController();
  TextEditingController pemakaiID = TextEditingController();
  TextEditingController pinjamdate = TextEditingController();
  TextEditingController pemakaicabang = TextEditingController();
  TextEditingController pemakaino = TextEditingController();
  TextEditingController pemakairs = TextEditingController();
  TextEditingController pemakaidokter = TextEditingController();
  TextEditingController paketname = TextEditingController();
  static File _image;
  String getcode = '';
  String getwocode;
  String message;
  String callimage;
  var pemakaian;
  var _pemakaian = Pemakaian();
  var _pemakaianService = Pemakaian_Item_Service();
  List<Pemakaian> _pemakaiList = <Pemakaian>[];

  var _pemakaian_item = Pemakaian_item();
  int pemakai_id;
  final String pinjam_date;
  final String pemakai_cabang;
  final String pemakai_no;
  final String pemakai_rs;
  final String pemakai_dokter;
  final String pemakai_status;
  final String paket_name;
  final String item_number;
  final String item_desc;
  int stock;
  final String item_satuan;
  final String lot_number;
  int status;
  _DetailLocalState(
      {
    this.pemakai_id,
    this.pinjam_date,
    this.pemakai_cabang,
    this.pemakai_no,
    this.pemakai_rs,
    this.pemakai_dokter,
    this.pemakai_status,
    this.paket_name,
    this.item_number,
    this.item_desc,
    this.stock,
    this.item_satuan,
    this.lot_number,
    this.status,
  });
  List<Pemakaian_item> _pemakaian_item_List = <Pemakaian_item>[];
  var _pemakaian_item_service = Pemakaian_Item_Service();

  @override
  void initState() {
    super.initState();
    getPemakaianItem();
  }

  Future<List> getPemakaianItem() async {
    var pemakaianitems = await _pemakaian_item_service
        .read_Pemakaian_ItemByPemakaiID(pemakai_id);
    return pemakaianitems;
  }

  scanbarcode(BuildContext context) async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Keluar", true, ScanMode.DEFAULT);
    print('Print GetCode :$getcode');

    getwocode = getcode.length > 29 ? getcode.substring(29) : "1";

    print('Print GetCode:$getwocode');
    setState(() {
      _edit_lot_numberCont.text = getwocode;
      message = 'Lot Tidak Ditemukan';
    });

    var itemList = await _pemakaian_item_service
        .read_Pemakaian_ItemByPemakaiID(pemakai_id);
    itemList.forEach((detailitem) {
      detailitem['id'];
      detailitem['pemakai_id'];
      detailitem['item_number'];
      detailitem['lot_number'];
      detailitem['pemakai_date'];
      if (detailitem['status'] == 1 &&
          detailitem['lot_number'] == _edit_lot_numberCont.text) {
        _pemakaian_item.id = detailitem['id'];
        _pemakaian_item.pemakai_id = detailitem['pemakai_id'];
        _pemakaian_item.item_number = detailitem['item_number'];
        _pemakaian_item.pemakai_date = detailitem['pemakai_date'];
        _pemakaian_item.lot_number = detailitem['lot_number'];
        _pemakaian_item.status = 2;
        _pemakaian_item.item_desc = detailitem['item_desc'];
        _pemakaian_item.item_satuan = detailitem['item_satuan'];
        _pemakaian_item.stock = detailitem['stock'];
        _pemakaian_item.status_desc = 'Pakai';
        message = 'success';
        var lot_number = detailitem['lot_number'];
        print("${_edit_lot_numberCont.text}");
        var result =
            _pemakaian_item_service.update_Pemakaian_Item(_pemakaian_item);
        var updateterpakai = _pemakaian_item_service
            .updateterpakai_Pemakaian_Item(pemakai_id, lot_number);
        getHeader();
        print(updateterpakai);
      }
      detailitem['status'];
      detailitem['item_desc'];
      detailitem['item_satuan'];
      detailitem['stock'];
      detailitem['status_desc'];
    });
    _message(context);
  }

  Future<List> getHeader() async {
    var getListHeader = await _pemakaianService.readPemakayById(pemakai_id);

    setState(() {
      Pinjam = getListHeader;
      pemakai_id = getListHeader[0]['pemakai_id'];

      print('counter value : $pemakai_id');
      print('counter value : $Pinjam');
    });
  }

  Future<void> getCameraImageGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile == null) {
      return;
    }
    print('Original path: $imageFile');

    final tempDir = await getTemporaryDirectory();
    var path = tempDir.path;

    String fileName =
        imageFile == null ? 'Kosong' : imageFile.path.split('/').last;
    print('filename: $fileName');

    setState(() {
      _image = imageFile;
      callimage = fileName;
    });
    print('file:$_image');
  }

  alert(BuildContext context) {
    print('hasil result:$callimage');
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Upload BAST",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(child: Text("Upload BAST", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Container(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: "${_image}" == 'Kosong'
                            ? AssetImage("assets/background/cancel.png")
                            : AssetImage("assets/background/checkmark.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            Divider(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: 20.0,
                height: 40.0,
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueAccent,
                        minimumSize: Size(70, 1),
                        padding: EdgeInsets.all(1.0)),
                    child: Container(
                      child: Text(
                        'Tutup',
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  Future PemakaiHeader() async {
    var getListHeader = await _pemakaianService.readPemakayById(pemakai_id);

    if (_image != null) {
      _pemakaian.id = getListHeader[0]['id'];
      _pemakaian.pemakai_by = "$userid";
      _pemakaian.pemakai_status = 2;
      _pemakaian.pemakai_bast = "$callimage";
      _pemakaian.status_description = 'Pakai';
      _pemakaian.teknisi = _teknisi.text;

      _pemakaian.pemakai_no = getListHeader[0]['pemakai_no'];
      _pemakaian.pemakai_id = getListHeader[0]['pemakai_id'];
      _pemakaian.pemakai_date = getListHeader[0]['pemakai_date'];
      _pemakaian.pemakai_cabang = getListHeader[0]['pemakai_cabang'];
      _pemakaian.pemakai_rs = getListHeader[0]['pemakai_rs'];
      _pemakaian.paket_name = getListHeader[0]['paket_name'];

      _pemakaian.pinjam_by = getListHeader[0]['pinjam_by'];
      _pemakaian.pemakai_dokter = getListHeader[0]['pemakai_dokter'];
      _pemakaian.pinjam_date = getListHeader[0]['pinjam_date'];
      _pemakaian.pemakai_paket = getListHeader[0]['pemakai_paket'];
      _pemakaian.created_at = getListHeader[0]['created_at'];
      _pemakaian.updated_at = getListHeader[0]['updated_at'];
      _pemakaianService.updatePemakaian(_pemakaian);
      _buildPopup(context);

      print('pemakai_no:${_pemakaian.pemakai_no}');
      print('pemakai_id:${_pemakaian.pemakai_id}');
      print('pemakai_date:${_pemakaian.pemakai_date}');
      print('pemakai_cabang:${_pemakaian.pemakai_cabang}');
      print('pemakai_rs:${_pemakaian.pemakai_rs}');

      print('pinjam_by:${'$userid'}');
      print('pemakai_dokter:${_pemakaian.pemakai_dokter}');
      print('pinjam_date:${_pemakaian.pinjam_date}');
      print('pemakai_paket:${_pemakaian.pemakai_paket}');
      print('created_at:${_pemakaian.created_at}');
      print('updated_at:${_pemakaian.updated_at}');

      print('pemakai_by:${_pemakaian.pemakai_by}');
      print('pemakai_status:${_pemakaian.pemakai_status}');
      print('pemakai_bast:${_pemakaian.pemakai_bast}');
      print('status_description:${_pemakaian.status_description}');
      print('teknisi:${_pemakaian.teknisi}');
    } 
  }

  _buildPopup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Pemakaian",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
              child: _image == null
                  ? Text('Belum Mengambil Gambar',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red))
                  : Text("Yeay,Berhasil Memakai Item",
                      style: TextStyle(
                          color: Colors.lightGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 20.0),
            ),
            Container(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: _image == null
                            ? AssetImage("assets/background/cancel.png")
                            : AssetImage("assets/background/checkmark.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 40.0),
            ),
            Center(
                child: Text(
              "Memakai Item Yang di Minta",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: 20.0,
                height: 40.0,
                child: _image == null
                    ? TextButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blueAccent,
                            minimumSize: Size(70, 1),
                            padding: EdgeInsets.all(1.0)),
                        child: Container(
                          child: Text(
                            'Tutup',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                    : TextButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blueAccent,
                            minimumSize: Size(70, 1),
                            padding: EdgeInsets.all(1.0)),
                        child: Container(
                          child: Text(
                            'Tutup',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataLocal()),
                          );
                        }),
              ),
            ),
          ],
        );
      },
    );
  }

  alertTopup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Top Up",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Silahkan Melakukan Proses Syncronize Terlebih Dahulu',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 20.0),
            ),
            Container(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.scaleDown,
                          image: AssetImage("assets/background/cancel.png")),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 40.0),
            ),
            Center(
                child: Text(
              "Harus Melakukan Syncronize",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )),
            Divider(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: 20.0,
                height: 40.0,
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueAccent,
                        minimumSize: Size(70, 1),
                        padding: EdgeInsets.all(1.0)),
                    child: Container(
                      child: Text(
                        'Tutup',
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  _message(context) {
    print('hasil result:$message');
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Scan Barcode",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Hasil Scanning", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Lot Number ${_edit_lot_numberCont.text}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: "$message" == 'success'
                        ? Colors.lightGreen
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                textAlign: (TextAlign.center),
                style: TextStyle(
                    color: "${message}" == 'success'
                        ? Colors.lightGreen
                        : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 20.0),
            ),
            Container(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: "${message}" == 'success'
                            ? AssetImage("assets/background/checkmark.png")
                            : AssetImage("assets/background/cancel.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),

            new Padding(
              padding: new EdgeInsets.only(top: 40.0),
            ),
            Divider(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: 20.0,
                height: 40.0,
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueAccent,
                        minimumSize: Size(70, 1),
                        padding: EdgeInsets.all(1.0)),
                    child: Container(
                      child: Text(
                        'Tutup',
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pemakai_id", _editpemakai_id.text);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unrelated_type_equality_checks
    if (pemakai_status.toString() == '1') {
      return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.green,
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_sharp,
                color: Colors.green,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataLocal()),
                );
              },
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFc7f2e9),
            title: Text(
              "Detail Pemakaian Barang",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/logos/phaprospattern.png"),
                    fit: BoxFit.cover)),
            child: ListView(
              children: [
                new Padding(
                  padding: new EdgeInsets.only(top: 10.0),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(top: 10.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Text(
                              'Detail Pemakaian',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 0,
                                                    height: 00,
                                                    child: Text("ID",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 0,
                                                    height: 0,
                                                    child: Text(
                                                        pemakai_id.toString(),
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 14,
                                                    child: Text(
                                                        "Tanggal Pinjam",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 70,
                                                    height: 12,
                                                    child: Text(pinjam_date,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 15,
                                                    child: Text('',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 70,
                                                    height: 15,
                                                    child: Text('',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text("Pemohon",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(pemakai_cabang,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text("Nomor Pinjam",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(pemakai_no,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text("Rumah Sakit",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(pemakai_rs,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text("Nama Dokter",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(pemakai_dokter,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text("Paket Operasi",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(paket_name,
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextButton.icon(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      10.0))),
                                                      primary:
                                                          Color(0xFFc7f2e9),
                                                      minimumSize: Size(300, 1),
                                                      elevation: 5,
                                                      padding:
                                                          EdgeInsets.all(11.0),
                                                    ),
                                                    onPressed: () {
                                                      scanbarcode(context);
                                                    },

                                                    label: Text(
                                                      'Scan Untuk Checking',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                                    icon: Icon(
                                                      Icons.all_out_outlined,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: _teknisi,
                          decoration: InputDecoration(
                              labelText: "Teknisi",
                              hintText: "Teknisi",
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                    ),
                  ],
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(top: 10.0),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            height: 20,
                                            child: Text("Daftar Pemakaian Item",
                                                style: TextStyle(fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 10.0),
                                      ),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              print('pEmAkAiAn:$pemakai_id');
                                              getCameraImageGallery();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              primary: Color(0xFFc7f2e9),
                                              minimumSize: Size(300, 1),
                                              elevation: 5,
                                              padding: EdgeInsets.all(11.0),
                                            ),

                                            label: Text(
                                              'Upload BAST',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                            icon: Icon(
                                              Icons.photo,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 10.0),
                                      ),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                              ),
                                              primary: Color(0xFFc7f2e9),
                                              minimumSize: Size(300, 1),
                                              elevation: 5,
                                              padding: EdgeInsets.all(11.0),
                                            ),
                                            onPressed: () async {
                                              var listpemakaikedua =
                                                  await _pemakaianService
                                                      .readPemakaikedua();
                                              setState(() {
                                                jml.text = listpemakaikedua[0]
                                                        ['jml']
                                                    .toString();
                                              });
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString("jmlh", jml.text);
                                              setState(() {
                                                jmlh = prefs.getString("jmlh");
                                              });
                                              print("$jmlh");
                                              print('Nilai jml:$jmlh');

                                              if ('$jmlh' == '0') {
                                                setIntoSharedPreferences();
                                                print("id:$pemakai_id");
                                                final response = await http.get(
                                                    "$base/index.php?r=api/view&model=pemakai&id=$pemakai_id");
                                                var jsonpemakai =
                                                    json.decode(response.body);
                                                setState(() {
                                                  Pinjam = jsonpemakai["data"];
                                                  print(
                                                      'counter value : $Pinjam');
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Topup(
                                                            Pinjam: Pinjam,
                                                          )),
                                                );
                                              } else {
                                                alertTopup(context);
                                              }
                                            },

                                            label: Text(
                                              'Top Up',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                            icon: Icon(
                                              Icons.money_outlined,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: new Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 250,
                                                      height: 20,
                                                      child: Text("Item Detail",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 165,
                                                      height: 30,
                                                      child: Text("Item",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 30,
                                                      child: Text("Stock",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 30,
                                                      child: Text("No Lot",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 350,
                                                      height: 153,
                                                      child:
                                                          FutureBuilder<List>(
                                                        future:
                                                            getPemakaianItem(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot.hasError)
                                                            print(
                                                                snapshot.error);
                                                          return snapshot
                                                                  .hasData
                                                              ? new IsiDetail(
                                                                  list: snapshot
                                                                      .data,
                                                                )
                                                              : new Center(
                                                                  child:
                                                                      new CircularProgressIndicator(),
                                                                );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            elevation: 4.0,
            backgroundColor: Color(0xFFc7f2e9),
            label: const Text(
              'Pakai',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              PemakaiHeader();
              _buildPopup(context);
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.green,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataLocal()),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Detail Pemakaian Barang",
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/logos/phaprospattern.png"),
                  fit: BoxFit.cover)),
          child: ListView(
            children: [
              new Padding(
                padding: new EdgeInsets.only(top: 10.0),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(top: 10.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Text(
                            'Detail Pemakaian',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Container(
                                                  width: 0,
                                                  height: 00,
                                                  child: Text("ID",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 0,
                                                  height: 0,
                                                  child: Text(
                                                      pemakai_id.toString(),
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 14,
                                                  child: Text("Tanggal Pinjam",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 70,
                                                  height: 12,
                                                  child: Text(pinjam_date,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 15,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 70,
                                                  height: 15,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text("Pemohon",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text(pemakai_cabang,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text("Nomor Pinjam",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text(pemakai_no,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text("Rumah Sakit",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text(pemakai_rs,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text("Nama Dokter",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text(pemakai_dokter,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text("Paket Operasi",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 30,
                                                  child: Text(paket_name,
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                    primary: Color(0xFFc7f2e9),
                                                    minimumSize: Size(300, 1),
                                                    elevation: 5,
                                                    padding:
                                                        EdgeInsets.all(11.0),
                                                  ),
                                                  onPressed: () {
                                                    scanbarcode(context);
                                                  },

                                                  label: Text(
                                                    'Scan Untuk Checking',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  ),
                                                  icon: Icon(
                                                    Icons.all_out_outlined,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: _teknisi,
                        decoration: InputDecoration(
                            labelText: "Teknisi",
                            hintText: "Teknisi",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                  ),
                ],
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(top: 10.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Container(
                                          width: 250,
                                          height: 20,
                                          child: Text("Daftar Pemakaian Item",
                                              style: TextStyle(fontSize: 14)),
                                        ),
                                      ],
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 10.0),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            print('pEmAkAiAn:$pemakai_id');
                                            getCameraImageGallery();

                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            primary: Color(0xFFc7f2e9),
                                            minimumSize: Size(300, 1),
                                            elevation: 5,
                                            padding: EdgeInsets.all(11.0),
                                          ),

                                          label: Text(
                                            'Upload BAST',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                          icon: Icon(
                                            Icons.photo,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 10.0),
                                    ),,
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                            ),
                                            primary: Color(0xFFc7f2e9),
                                            minimumSize: Size(300, 1),
                                            elevation: 5,
                                            padding: EdgeInsets.all(11.0),
                                          ),
                                          onPressed: () async {
                                            var listpemakaikedua =
                                                await _pemakaianService
                                                    .readPemakaikedua();
                                            setState(() {
                                              jml.text = listpemakaikedua[0]
                                                      ['jml']
                                                  .toString();
                                            });
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString("jmlh", jml.text);
                                            setState(() {
                                              jmlh = prefs.getString("jmlh");
                                            });
                                            print("$jmlh");
                                            print('Nilai jml:$jmlh');

                                            if ('$jmlh' == '0') {
                                              setIntoSharedPreferences();
                                              print("id:$pemakai_id");
                                              final response = await http.get(
                                                  "$base/index.php?r=api/view&model=pemakai&id=$pemakai_id");
                                              var jsonpemakai =
                                                  json.decode(response.body);
                                              setState(() {
                                                Pinjam = jsonpemakai["data"];
                                                print(
                                                    'counter value : $Pinjam');
                                              });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Topup(
                                                          Pinjam: Pinjam,
                                                        )),
                                              );
                                            } else {
                                              alertTopup(context);
                                            }
                                          },

                                          label: Text(
                                            'Top Up',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                          icon: Icon(
                                            Icons.money_outlined,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 10.0),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: new Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 250,
                                                    height: 20,
                                                    child: Text("Item Detail",
                                                        style: TextStyle(
                                                            fontSize: 14)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 165,
                                                    height: 30,
                                                    child: Text("Item",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  Container(
                                                    width: 100,
                                                    height: 30,
                                                    child: Text("Stock",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  Container(
                                                    width: 100,
                                                    height: 30,
                                                    child: Text("No Lot",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 350,
                                                    height: 153,
                                                    child: FutureBuilder<List>(
                                                      future:
                                                          getPemakaianItem(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.hasError)
                                                          print(snapshot.error);
                                                        return snapshot.hasData
                                                            ? new IsiDetail(
                                                                list: snapshot
                                                                    .data,
                                                              )
                                                            : new Center(
                                                                child:
                                                                    new CircularProgressIndicator(),
                                                              );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class IsiDetail extends StatelessWidget {
  List list;
  IsiDetail({this.list});
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return new Container(
          padding: const EdgeInsets.all(5.0),
          child: new GestureDetector(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 140,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(list[i]['item_number'],
                              style: TextStyle(fontSize: 12)),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(list[i]['item_desc'],
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 70,
                  ),
                  Container(
                    width: 20,
                    height: 70,
                    child: Text(list[i]['stock'].toString(),
                        style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    width: 25,
                    height: 70,
                    child: Text(list[i]['item_satuan'].toString(),
                        style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    width: 30,
                    height: 70,
                  ),
                  Container(
                    width: 100,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                                list[i]['lot_number'] == null
                                    ? "Not Set"
                                    : list[i]['lot_number'],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: list[i]['lot_number'] == null
                                        ? Colors.red
                                        : Colors.black))

                            ),
                        Align(
                          alignment: Alignment.center,
                          child: ButtonTheme(
                            minWidth: 20.0,
                            height: 20.0,
                            child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  primary: list[i]['status'] == 1
                                      ? Colors.blue
                                      : list[i]['status'] == 2
                                          ? Colors.green
                                          : Colors.red,
                                  minimumSize: Size(70, 1),
                                  padding: EdgeInsets.all(1.0),
                                ),
                                child: Container(
                                  child: Text(
                                    list[i]['status'] == 1
                                        ? "Pinjam"
                                        : list[i]['status'] == 2
                                            ? "Pakai"
                                            : "Terpakai",
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.white),
                                  ),
                                ),
                                onPressed: () {
                                  
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
