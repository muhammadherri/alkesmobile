import 'dart:convert';
import 'dart:async';
import 'package:alkes/menu/PemakaianItem/datalocal.dart';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:alkes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Topup extends StatefulWidget {
  final Widget child;
  final Pemakaian contact;
  final Pinjam;
  final response;
  Topup({this.Pinjam, this.response, this.child, this.contact});

  @override
  _TopupState createState() => _TopupState(
        pemakai_id: this.Pinjam['pemakai_id'].toString(),
        pemakai_cabang: this.Pinjam['pemakai_cabang'].toString(),
        pemakai_no: this.Pinjam['pemakai_no'].toString(),
        pemakai_rs: this.Pinjam['pemakai_rs'].toString(),
        pemakai_dokter: this.Pinjam['pemakai_dokter'].toString(),
        pinjam_date: this.Pinjam['pinjam_date'].toString(),
        paket_name: this.Pinjam['paket_name'].toString(),
      );
}

class _TopupState extends State<Topup> {
  var _pemakaian = Pemakaian();
  var _pemakaianService = Pemakaian_Item_Service();
  var pemakaian;
  var _pemakaian_item_service = Pemakaian_Item_Service();
  var _pemakaian_item = Pemakaian_item();

  String id;
  final String pemakai_cabang;
  final String paket_name;
  final String pemakai_dokter;
  final String pemakai_rs;
  final String pemakai_status;
  final String pemakai_no;
  final String pemakai_date;
  final String pinjam_by;
  final String pinjam_date;
  final String pemakai_by;
  final String pemakai_paket;
  final String created_at;
  final String updated_at;
  final String status_name;
  final String pemakai_id;
  final String lot_number;
  final String status;
  final String item_number;
  final String item_desc;
  final String item_satuan;
  final String stock;
  final String status_desc;

  Pemakaian contact;
  _TopupState(
      {this.pemakai_id,
      this.pemakai_cabang,
      this.pemakai_no,
      this.pemakai_rs,
      this.lot_number,
      this.status,
      this.item_number,
      this.item_desc,
      this.item_satuan,
      this.stock,
      this.status_desc,
      this.created_at,
      this.paket_name,
      this.pemakai_by,
      this.pemakai_date,
      this.pemakai_dokter,
      this.pemakai_paket,
      this.pemakai_status,
      this.pinjam_by,
      this.pinjam_date,
      this.status_name,
      this.updated_at,
      this.contact});
  List<Pemakaian_item> _pemakaianItemList = <Pemakaian_item>[];

  String PemakaiID = "";
  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);

    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
    });
  }

  TextEditingController namabarang = TextEditingController();
  TextEditingController PemakaiId = TextEditingController();
  void UpdatePinjambarcode() async {
    var url = "$base/index.php?r=api/pemakaiaddlot&id=$PemakaiID";
    http.post(url, body: {
      "mode": "pinjam",
      "lot_number": namabarang.text,
      "status": "1",
    });
  }
  Future<List> getListPinjam() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid");
    return json.decode(response.body);
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/pemakaiitem&id=$pemakai_id&status=");
    var dataitem = json.decode(response.body);

    _pemakaianItemList = <Pemakaian_item>[];
    return dataitem;
  }

  List<Pemakaian_item> bookdetails = [];
  void addData() {
    var url = "http://192.168.1.9:8080/alkes/adddatabarang.php";
    http.post(url, body: {
      "namabarang": namabarang.text,
    });
  }

  String code = "";
  String getcode = "";
  String message = "";
  Future scanbar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
    });
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      namabarang.text = getcode;
    });
    final response = await http
        .post("$base/index.php?r=api/pemakaiaddlot&id=$pemakai_id", body: {
      "lot_number": namabarang.text,
      "mode": "pinjam",
      "status": "1",
    });
    var jsonmessage = json.decode(response.body);
    setState(() {
      message = jsonmessage["message"];
      print('counter value : $namabarang.text');
      print('counter value : $message');
      print('counter value : $pemakai_id');
    });
    _message(context);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  Future synctoserver() async {
    var listpemakai = await _pemakaianService.readPemakai();
    listpemakai.forEach((pakai) async {
      if (pakai["pemakai_status"] == 2) {
        var PemakaiId = pakai["pemakai_id"];
        var namafile = pakai['pemakai_bast'];
        var status = pakai['pemakai_status'];
        var listPemakaiItem = await _pemakaian_item_service
            .read_Pemakaian_ItemByPemakaiID(PemakaiId);

        print('$listPemakaiItem["status"]');

        listPemakaiItem.forEach((item) {
          if (item['status'] == 2) {
            var itemNumber = item["item_number"];
            var lotNumber = item["lot_number"];
            var statuspemakaianitem = item["status"];
            var url =
                "$base/index.php?r=api/update&model=pemakaiitem&id=$PemakaiId";
            http.post(url, body: {
              "item_number": '$itemNumber',
              "Pemakaiitem[lot_number]": '$lotNumber',
              "Pemakaiitem[status]": '$statuspemakaianitem',
            });
            print('Upload pemakaian item');
            print('item number:$itemNumber');
            print('lot number :$lotNumber');
            print('status :$statuspemakaianitem');
          }
        });
        print('$PemakaiId');
        var bastfile =
            '/storage/emulated/0/Android/data/com.phapros.alkes/files/Pictures/$namafile';
        final url = Uri.parse(
            "$base/index.php?r=api/update&model=pemakai&id=$PemakaiId");
        var request = http.MultipartRequest('POST', url);
        request.fields["Pemakai[pemakai_status]"] = '$status';
        request.fields["Pemakai[pemakai_bast]"] = '$namafile';
        request.fields["Pemakai[teknisi]"] = pakai["teknisi"];

        print('hasilfile : $bastfile');
        print('Upload Pemakai');
        print('sttus pemakai $PemakaiId ');
        print('namafile $namafile ');
        print('status$status');
var pic = http.MultipartFile.fromPath("bast", '$bastfile');
        var response = request.send();
      }
    });
    _pemakaianService.deletePemakai_status();
    _pemakaian_item_service.Delete_Pemakaian_Item();
    await new Future.delayed(const Duration(seconds: 5));
    final response = await http.get(
        "$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid&pemakai_status=1");
    var listPeminjam = json.decode(response.body);
    listPeminjam.forEach((pinjam) {
      syncPemakai(pinjam);
    });
    _pemakaianService.updatesync();

  }

  syncPemakai(pinjam) async {
    _pemakaian.pemakai_id = pinjam['pemakai_id'];
    _pemakaian.pemakai_cabang = pinjam['pemakai_cabang'].toString();
    _pemakaian.pemakai_date = pinjam['pemakai_date'].toString();
    _pemakaian.pemakai_dokter = pinjam['pemakai_dokter'].toString();
    _pemakaian.pemakai_no = pinjam['pemakai_no'].toString();
    _pemakaian.pemakai_rs = pinjam['pemakai_rs'].toString();
    _pemakaian.pemakai_status = pinjam['pemakai_status'];
    _pemakaian.pemakai_paket = pinjam['pemakai_paket'].toString();
    _pemakaian.teknisi = pinjam['teknisi'];
    _pemakaian.paket_name = pinjam['paket_name'];
    _pemakaian.pinjam_date = pinjam['pinjam_date'];
    _pemakaianService.savePemakaian(_pemakaian);
    print('Download Pemakai');
    print('pemakai_id:${_pemakaian.pemakai_id}');
    print('pemakai_cabang:${_pemakaian.pemakai_cabang}');
    print('pemakai_date:${_pemakaian.pemakai_date}');
    print('pemakai_dokter:${_pemakaian.pemakai_dokter}');
    print('pemakai_no:${_pemakaian.pemakai_no}');
    print('pemakai_rs:${_pemakaian.pemakai_rs}');
    print('pemakai_status:${_pemakaian.pemakai_status}');
    print('pemakai_paket:${_pemakaian.pemakai_paket}');
    print('teknisi:${_pemakaian.teknisi}');
    print('paket_name:${_pemakaian.paket_name}');
    print('pinjam_date:${_pemakaian.pinjam_date}');
    var pemakaiId = pinjam['pemakai_id'];

    print("$pemakaiId");
    final response = await http
        .get("$base/index.php?r=api/pemakaiitem&status=1&id=$pemakaiId&sync=1");
    var listPeminjamItem = json.decode(response.body);

    listPeminjamItem.forEach((item) {
      syncPemakaiItem(item);
    });
  }

  syncPemakaiItem(item) async {
    _pemakaian_item.pemakai_id = item['pemakai_id'];
    _pemakaian_item.item_desc = item['item_desc'];
    _pemakaian_item.item_number = item['item_number'];
    _pemakaian_item.item_satuan = item['item_satuan'];
    _pemakaian_item.lot_number = item['lot_number'];
    _pemakaian_item.status = item['status'];
    _pemakaian_item.status_desc = item['status_desc'];
    _pemakaian_item.stock = item['stock'];
    _pemakaian_item_service.save_Pemakaian_Item(_pemakaian_item);
    print('Download Pemakaian Detail Item');
    print('pemakai_id:${_pemakaian_item.pemakai_id}');
    print('item_desc:${_pemakaian_item.item_desc}');
    print('item_number:${_pemakaian_item.item_number}');
    print('item_satuan:${_pemakaian_item.item_satuan}');
    print('lot_number:${_pemakaian_item.lot_number}');
    print('status:${_pemakaian_item.status}');
    print('status_desc:${_pemakaian_item.status_desc}');
    print('stock:${_pemakaian_item.stock}');
  }

  Alert(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return SimpleDialog(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "SYNC TO SERVER",
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Proses Sync', textAlign: (TextAlign.center)),
              ),
              new Padding(
                padding: new EdgeInsets.only(top: 20.0),
              ),
               Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 5), child: Text("Loading")),
                ],
              ),
              Divider(),
             ],
          );
        });
  }

  Loading(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return SimpleDialog(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "SYNC TO SERVER",
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('SYNC TO SERVER BERHASIL', textAlign: (TextAlign.center)),
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
                            image:
                                AssetImage("assets/background/checkmark.png")),
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
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.green,
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Top Up",
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
            padding:
                const EdgeInsets.only(top: 0.0, bottom: 0, left: 0, right: 0),
            child: Builder(
               builder: (BuildContext context) {
            return OfflineBuilder(
connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity, Widget child) {
                final bool connected = connectivity != ConnectivityResult.none;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      height: 32.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: connected ? null : Color(0xFFEE4400),
                        child: connected
                            ? null
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Anda Sedang OFFLINE",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                    height: 12.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              },
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
                                'Detail TopUp',
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
                                                      width: 180,
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
                                                      width: 180,
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
                                                      width: 180,
                                                      height: 30,
                                                      child: Text("Pemohon",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 100,
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
                                                      width: 180,
                                                      height: 30,
                                                      child: Text("Nomor Pinjam",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 100,
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
                                                      width: 180,
                                                      height: 30,
                                                      child: Text("Rumah Sakit",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 100,
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
                                                      width: 180,
                                                      height: 30,
                                                      child: Text("Nama Dokter",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 100,
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
                                                      width: 180,
                                                      height: 30,
                                                      child: Text("Paket Operasi",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 30,
                                                      child: Text(paket_name,
                                                          style: TextStyle(
                                                              fontSize: 12)),
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
                                              child: Text("Daftar TopUp",
                                                  style: TextStyle(fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.only(top: 10.0),
                                        ),
            
                                        Center(
                                          child: Row(
                                            children: [
                                              ButtonTheme(
                                                minWidth: 300.0,
                                                height: 40.0,
                                                child: TextButton.icon(
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
                                                  onPressed: () => {
                                                    scanbar(),
                                                    print(
                                                        'pemakai_id:${"$PemakaiID"}'),
                                                    print(
                                                        'lot_number:${namabarang.text}'),
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
                                              ),
                                            ],
                                          ),
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.only(top: 10.0),
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
                                                          future: getData(),
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
              ));}
            )),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFc7f2e9),
          label: const Text(
            'BACK',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            synctoserver();
            Alert(context);
             await new Future.delayed(
                                      const Duration(seconds: 1));
            await new Future.delayed(const Duration(seconds: 1));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataLocal()),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
  }

  void _message(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$message",
                    style: TextStyle(
                        color: "$message" == 'success'
                            ? Colors.lightGreen
                            : Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )),
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
                        image: "$message" == 'success'
                            ? AssetImage("assets/background/checkmark.png")
                            : AssetImage("assets/background/cancel.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
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

}

class IsiDetail extends StatefulWidget {
  List list;
  int i;
  IsiDetail({this.list, this.i});

  @override
  _IsiDetailState createState() => _IsiDetailState();
}

class _IsiDetailState extends State<IsiDetail> {
  String pemakai_id;
  String item_number;
  String pemakai_date;
  String lot_number;
  String status;
  String item_desc;
  String item_satuan;
  String stock;
  String status_desc;
  var pemakaian;
  TextEditingController PemakaiId = TextEditingController();
  void getIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pemakai_id", PemakaiId.text);
    setState(() {
      pemakai_id = prefs.getString("pemakai_id");
    });
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/pemakaiitem&id=$pemakai_id&status=0");
    return json.decode(response.body);
  }
  String NamaBarang = "";
  void getScan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      NamaBarang = prefs.getString("NamaBarang");
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        getData();
        return Future.value(false);
      },
      child: new ListView.builder(
        itemCount: widget.list == null ? 0 : widget.list.length,
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
                            child: Text(widget.list[i]['item_number'],
                                style: TextStyle(fontSize: 12)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.list[i]['item_desc'],
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
                      child: Text(widget.list[i]['stock'],
                          style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      width: 25,
                      height: 70,
                      child: Text(widget.list[i]['item_satuan'],
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
                                  widget.list[i]['lot_number'] == null
                                      ? "Not Set"
                                      : widget.list[i]['lot_number'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          widget.list[i]['lot_number'] == null
                                              ? Colors.red
                                              : Colors.black))),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(70, 1),
                                  padding: EdgeInsets.all(1.0),
                                  primary: widget.list[i]['status'] == 0
                                      ? Colors.red
                                      : widget.list[i]['status'] == 1
                                          ? Colors.green
                                          : widget.list[i]['status'] == 2
                                              ? Colors.blueAccent
                                              : Colors.orange,
                                ),
                                child: Container(
                                  child: Text(
                                    widget.list[i]['status_desc'],
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.white),
                                  ),
                                ),
                                onPressed: () {
                                }),
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
      ),
    );
  }
}
