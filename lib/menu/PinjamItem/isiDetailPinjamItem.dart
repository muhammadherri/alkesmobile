import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:alkes/menu/PinjamItem/deletepinjam.dart';
import 'package:alkes/menu/PinjamItem/listPinjamItem.dart';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:alkes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IsiDetailPinjamItem extends StatefulWidget {
  final Widget child;
  final Pemakaian contact;
  final Pinjam;
  final response;
  IsiDetailPinjamItem({this.Pinjam, this.response, this.child, this.contact});

  @override
  _IsiDetailPinjamItemState createState() => _IsiDetailPinjamItemState(
        pemakai_id: this.Pinjam['pemakai_id'],
        pemakai_cabang: this.Pinjam['pemakai_cabang'].toString(),
        pemakai_no: this.Pinjam['pemakai_no'].toString(),
        pemakai_rs: this.Pinjam['pemakai_rs'].toString(),
        pemakai_dokter: this.Pinjam['pemakai_dokter'].toString(),
        pinjam_date: this.Pinjam['pinjam_date'].toString(),
        pemakai_date: this.Pinjam['pemakai_date'].toString(),
        paket_name: this.Pinjam['paket_name'].toString(),
        pemakai_status: this.Pinjam['pemakai_status'].toString(),
      );
}

class _IsiDetailPinjamItemState extends State<IsiDetailPinjamItem> {
  var Pinjam;
  var _pemakaianService = Pemakaian_Item_Service();
  var jml = TextEditingController();
  String jmlh;
  File file;
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
  int pemakai_id;
  final String pemakaii_id;
  final String lot_number;
  final String status;
  final String item_number;
  final String item_desc;
  final String item_satuan;
  final String stock;
  final String status_desc;

  Pemakaian contact;
  _IsiDetailPinjamItemState(
      {this.pemakai_id,
      this.pemakaii_id,
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
  var pemakaian;
  String PemakaiID = "";
  TextEditingController namabarang = TextEditingController();
  TextEditingController PemakaiId = TextEditingController();
  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);

    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
      print('counter value : $PemakaiID');
    });
  }
  Future<List> getListPinjam() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid");
    return json.decode(response.body);
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/pemakaiitem&id=$pemakai_id&status=0");
    var dataitem = json.decode(response.body);
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
  String lot_numbers = "";
  Future scanbar() async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      namabarang.text = getcode;
    });
    final response = await http
        .post("$base/index.php?r=api/pemakaiaddlot&id=$PemakaiID", body: {
      "lot_number": namabarang.text,
      "mode": "pinjam",
      "status": "1",
    });
    var jsonmessage = json.decode(response.body);
    setState(() {
      message = jsonmessage["message"];
      lot_numbers = jsonmessage["lot_number"].toString();
      print('counter value : $namabarang.text');
      print('counter value : $message');
      print('counter value : $PemakaiID');
    });
    _message(context);
  }

  @override
  void initState() {
    super.initState();
    PemakaiId.text = pemakai_id.toString();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  Future<String> uploadImage(filepath, url) async {
    final request = http.MultipartRequest('POST', (url));
    request.files.add(http.MultipartFile('Pemakai[bast]',
        File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
        filename: filepath.split("/").last));
    var res = await request.send();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (pemakai_status.toString() == '0') {
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
                  MaterialPageRoute(builder: (context) => ListPinjamItem()),
                );
              },
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFc7f2e9),
            title: Text(
              "Detail Peminjaman Barang",
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
                                'Detail Pinjam',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      width: 140,
                                                      height: 14,
                                                      child: Text(
                                                          "Tanggal Kebutuhan",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      height: 12,
                                                      child: Text(pemakai_date,
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
                                                      width: 140,
                                                      height: 30,
                                                      child: Text("Pemohon",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 140,
                                                      height: 30,
                                                      child: Text(
                                                          pemakai_cabang,
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
                                                      child: Text(
                                                          "Nomor Pinjam",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    Container(
                                                      width: 150,
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
                                                      width: 100,
                                                      height: 30,
                                                      child: Text(
                                                          pemakai_dokter,
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
                                                      child: Text(
                                                          "Paket Operasi",
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
                                              child: Text("Daftar Pinjam Item",
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(top: 10.0),
                                        ),

                                        Center(
                                          child: Row(
                                            children: [
                                              ButtonTheme(
                                                minWidth: 300.0,
                                                height: 40.0,
                                                child: TextButton.icon(
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
                                                  onPressed: () => {
                                                    setIntoSharedPreferences(),
                                                    scanbar(),
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
                                          padding:
                                              new EdgeInsets.only(top: 10.0),
                                        ),
                                       
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(top: 10.0),
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
                                                        child: Text(
                                                            "Item Detail",
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
                                                            if (snapshot
                                                                .hasError)
                                                              print(snapshot
                                                                  .error);
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
              )),
          floatingActionButton: FloatingActionButton.extended(
            elevation: 4.0,
            backgroundColor: Color(0xFFc7f2e9),
            label: const Text(
              'Pinjam',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              var listpemakaikedua = await _pemakaianService.readPemakaikedua();
              setState(() {
                jml.text = listpemakaikedua[0]['jml'].toString();
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("jmlh", jml.text);
              setState(() {
                jmlh = prefs.getString("jmlh");
              });
              print("$jmlh");
              print('Nilai jml:$jmlh');
              if ('$jmlh' == '0') {
                var url =
                    "$base/index.php?r=api/update&model=pemakai&id=$pemakai_id";
                http.post(url, body: {
                  "Pemakai[pemakai_status]": "1",
                });
                _buildPopupDialog(context);
              } else {
                alertTopup(context);
              }
              print('_pemakai_id:_pemakaian.pemakai_id');
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
                MaterialPageRoute(builder: (context) => ListPinjamItem()),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Detail Peminjaman Barang",
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
                              'Detail Pinjam',
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
                                                    width: 150,
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
                Container(
                  height: 350,
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
                                                      height: 250,
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
                                                              ? new IsiDetailKeDua(
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
            )),
      );
    }
  }

  void _message(context) {
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
                "Lot Number $lot_numbers",
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
                "$message",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: "$message" == 'success'
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
                        image: "$message" == 'success'
                            ? AssetImage("assets/background/checkmark.png")
                            : AssetImage("assets/background/cancel.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 80.0),
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

  void _buildPopupDialog(context) {
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
                      "Pinjam",
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
                "Yeay,Berhasil Meminjam Item",
                style: TextStyle(
                    color: Colors.lightGreen,
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
                        image: AssetImage("assets/background/checkmark.png"),
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
              "Meminjam Item Yang di Minta",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListPinjamItem()),
                      );
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
  final String message;
  List list;
  IsiDetail({this.list, this.message});

  @override
  _IsiDetailState createState() => _IsiDetailState();
}

class _IsiDetailState extends State<IsiDetail> {
  var Pinjam;

  List list;
  TextEditingController Lot_Number = TextEditingController();
  String PemakaiID = "";
  TextEditingController PemakaiId = TextEditingController();
  String LT_Number = "";
  void getIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
    });
  }

  Future<List> getData() async {
    final response = await http.get(
        "$base/index.php?r=api/pemakaiitem&id=$PemakaiID&status=0"
        );

    return json.decode(response.body);
  }

  TextEditingController reqid = new TextEditingController();
  TextEditingController pemakai_cabang = new TextEditingController();
  TextEditingController pemakai_no = new TextEditingController();
  TextEditingController pemakai_rs = new TextEditingController();
  TextEditingController pemakai_dokter = new TextEditingController();
  TextEditingController pemakai_paket = new TextEditingController();
  TextEditingController pinjam_date = new TextEditingController();
  void getDataheader() async {
    final response = await http
        .get("$base/index.php?r=api/view&model=pemakai&id=$PemakaiID");
    var jsonrequest = json.decode(response.body);
    setState(() {
      Pinjam = jsonrequest["data"];
      reqid.text = Pinjam["pemakai_id"].toString();
      pemakai_cabang.text = Pinjam["pemakai_cabang"];
      pemakai_no.text = Pinjam["pemakai_no"];
      pemakai_rs.text = Pinjam["pemakai_rs"];
      pemakai_dokter.text = Pinjam["pemakai_dokter"];
      pemakai_paket.text = Pinjam["pemakai_paket"];
      pinjam_date.text = Pinjam["pinjam_date"];
      print('counter value : $Pinjam');
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => IsiDetailPinjamItem(
                Pinjam: Pinjam,
              )),
    );
  }

  Future setLotNum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("LT_Number", Lot_Number.text);
    setState(() {
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
  }

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
      print('counter value : $PemakaiID');
    });
  }

  Future deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    await prefs.setString("LT_Number", Lot_Number.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
      print('counter value : $PemakaiID');
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
    var url =
        "$base/index.php?r=api/pemakaideletelot&pemakai_id=$PemakaiID&lot_number=$LT_Number";
    http.get(url);
    print('$url');

    getDataheader();
    getData();
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
                        "Delete Data",
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
                child: Text('Delete Berhasil', textAlign: (TextAlign.center)),
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
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: widget.list == null ? 0 : widget.list.length,
      itemBuilder: (context, i) {
        return new Container(
          padding: const EdgeInsets.all(0.0),
          child: new GestureDetector(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      height: 70,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                Lot_Number.text = widget.list[i]['item_number'],
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
                      child: Text(
                        PemakaiId.text =
                            widget.list[i]['pemakai_id'].toString(),
                        style: TextStyle(fontSize: 0),
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
                      width: 20,
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
                                  (widget.list[i]['lot_number'] == null ||
                                          widget.list[i]['lot_number'] == '')
                                      ? "Not Set"
                                      : widget.list[i]['lot_number'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: widget.list[i]['lot_number'] ==
                                                  null ||
                                              widget.list[i]['lot_number'] == ''
                                          ? Colors.red
                                          : Colors.black))),
                          Align(
                            alignment: Alignment.center,
                            child: ButtonTheme(
                              minWidth: 20.0,
                              height: 20.0,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                    primary: widget.list[i]['status'] == 0
                                        ? Colors.red
                                        : widget.list[i]['status'] == 1
                                            ? Colors.green
                                            : Colors.blueAccent,
                                    minimumSize: Size(70, 1),
                                    padding: EdgeInsets.all(1.0)),
                                child: Container(
                                  child: Text(widget.list[i]['status_desc'],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white,
                                      )),
                                ),
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            IsiDetailPinjamItem()),
                                  )
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 70,
                    ),
                    Container(
                      width: 50,
                      height: 70,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async{
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DeletePinjam(
                                            list: widget.list,
                                            index: i,
                                          )));
                            },
                            child: Align(
                                alignment: Alignment.center,
                                child: Text('Hapus',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IsiDetailKeDua extends StatefulWidget {
  final String message;
  List list;
  IsiDetailKeDua({this.list, this.message});

  @override
  _IsiDetailKeDuaState createState() => _IsiDetailKeDuaState();
}

class _IsiDetailKeDuaState extends State<IsiDetailKeDua> {
  var Pinjam;

  List list;
  TextEditingController Lot_Number = TextEditingController();
  String PemakaiID = "";
  TextEditingController PemakaiId = TextEditingController();

  String LT_Number = "";
  void getIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
    });
  }

  Future<List> getData() async {
    final response = await http.get(
        "$base/index.php?r=api/pemakaiitem&id=$PemakaiID&status=0"
        );

    return json.decode(response.body);
  }

  TextEditingController reqid = new TextEditingController();
  TextEditingController pemakai_cabang = new TextEditingController();
  TextEditingController pemakai_no = new TextEditingController();
  TextEditingController pemakai_rs = new TextEditingController();
  TextEditingController pemakai_dokter = new TextEditingController();
  TextEditingController pemakai_paket = new TextEditingController();
  TextEditingController pinjam_date = new TextEditingController();
  void getDataheader() async {
    final response = await http
        .get("$base/index.php?r=api/view&model=pemakai&id=$PemakaiID");
    var jsonrequest = json.decode(response.body);
    setState(() {
      Pinjam = jsonrequest["data"];
      reqid.text = Pinjam["pemakai_id"].toString();
      pemakai_cabang.text = Pinjam["pemakai_cabang"];
      pemakai_no.text = Pinjam["pemakai_no"];
      pemakai_rs.text = Pinjam["pemakai_rs"];
      pemakai_dokter.text = Pinjam["pemakai_dokter"];
      pemakai_paket.text = Pinjam["pemakai_paket"];
      pinjam_date.text = Pinjam["pinjam_date"];
      print('counter value : $Pinjam');
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => IsiDetailPinjamItem(
                Pinjam: Pinjam,
              )),
    );
  }

  Future setLotNum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("LT_Number", Lot_Number.text);
    setState(() {
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
  }

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
      print('counter value : $PemakaiID');
    });
  }

  Future deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    await prefs.setString("LT_Number", Lot_Number.text);
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
      print('counter value : $PemakaiID');
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
    var url =
        "$base/index.php?r=api/pemakaideletelot&pemakai_id=$PemakaiID&lot_number=$LT_Number";
    http.get(url);
    print('$url');

    getDataheader();
    getData();
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
                        "Delete Data",
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
                child: Text('Delete Berhasil', textAlign: (TextAlign.center)),
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
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: widget.list == null ? 0 : widget.list.length,
      itemBuilder: (context, i) {
        return new Container(
          padding: const EdgeInsets.all(0.0),
          child: new GestureDetector(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      height: 70,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                Lot_Number.text = widget.list[i]['item_number'],
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
                      child: Text(
                        PemakaiId.text =
                            widget.list[i]['pemakai_id'].toString(),
                        style: TextStyle(fontSize: 0),
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
                      width: 20,
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
                                  (widget.list[i]['lot_number'] == null ||
                                          widget.list[i]['lot_number'] == '')
                                      ? "Not Set"
                                      : widget.list[i]['lot_number'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: widget.list[i]['lot_number'] ==
                                                  null ||
                                              widget.list[i]['lot_number'] == ''
                                          ? Colors.red
                                          : Colors.black))),
                          Align(
                            alignment: Alignment.center,
                            child: ButtonTheme(
                              minWidth: 20.0,
                              height: 20.0,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                    primary: widget.list[i]['status'] == 0
                                        ? Colors.red
                                        : widget.list[i]['status'] == 1
                                            ? Colors.green
                                            : Colors.blueAccent,
                                    minimumSize: Size(70, 1),
                                    padding: EdgeInsets.all(1.0)),
                                child: Container(
                                  child: Text(widget.list[i]['status_desc'],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white,
                                      )),
                                ),
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            IsiDetailPinjamItem()),
                                  )
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
