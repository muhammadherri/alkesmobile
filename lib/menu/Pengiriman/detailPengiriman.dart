import 'dart:convert';
import 'package:alkes/menu/Pengiriman/pengiriman.dart';
import 'package:alkes/menu/Pengiriman/updateDataPengiriman.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alkes/main.dart';

class DetailPengiriman extends StatefulWidget {
  final String base;
  final Request;
  DetailPengiriman({this.Request, this.base});

  @override
  _DetailPengirimanState createState() => _DetailPengirimanState(
      request_id: this.Request['request_id'].toString(),
      request_date: this.Request['request_date'].toString(),
      request_from: this.Request['request_from'].toString(),
      surat_jalan_no: this.Request['surat_jalan_no'].toString(),
      request_no: this.Request['request_no'].toString());
}

class _DetailPengirimanState extends State<DetailPengiriman> {
  final String request_id;
  final String request_date;
  final String request_from;
  final String request_no;
  final String surat_jalan_no;
  _DetailPengirimanState(
      {this.request_id,
      this.request_date,
      this.surat_jalan_no,
      this.request_no,
      this.request_from});
  String RequestID = "";

  TextEditingController namabarang = TextEditingController(text: "");
  TextEditingController RequestId = TextEditingController();

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("RequestID", RequestId.text);
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
  }

  void updateDataPengiriman() {
    var url = "$base/index.php?r=api/update&model=request&id=$request_id";
    http.post(url, body: {
      "Request[request_status]": "5",
      "Request[approve_by]": "$userid",
    });
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/requestitem&id=$request_id&status=1");

    return json.decode(response.body);
  }
  String code = "";
  String getcode = "";
  String message = "";
  String lot_numbers = "";

  Future scanbarcode() async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      namabarang.text = getcode;
    });
    final response = await http
        .post("$base/index.php?r=api/requestaddlot&id=$RequestID", body: {
      "request_id": "$RequestID",
      "lot_number": namabarang.text,
      "status": "1",
      "mode": "kirim"
    });
    var jsonmessage = json.decode(response.body);
    setState(() {
      message = jsonmessage["message"];
      lot_numbers = jsonmessage["lot_number"].toString();
      print('counter value : $message');
    });
    _message(context);
  }

  @override
  void initState() {
    super.initState();
    RequestId.text = widget.Request['request_id'].toString();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
            "Detail Pengiriman Barang",
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
                              'Detail Pengiriman',
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
                                                        "Tanggal Pengiriman",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 70,
                                                    height: 14,
                                                    child: Text(request_date,
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
                                                    child: Text(
                                                        "Tujuan Pengiriman",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(request_from,
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
                                                        "Nomor Pengiriman",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(surat_jalan_no,
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
                                            child: Text("Daftar Pengirim",
                                                style: TextStyle(fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 10.0),
                                      ),
                                      Center(
                                        child: Row(children: [
                                          TextButton.icon(
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
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .push(new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new UpdateDataPengiriman(
                                                      Request: widget.Request
                                                      ),
                                            )),

                                            label: Text(
                                              'Tambah Alamat Pengiriman',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                            icon: Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ]),
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
                                                      width: 265,
                                                      height: 30,
                                                      child: Text("Item",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 140,
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
            )),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFc7f2e9),
          label: const Text(
            'Kirim',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            updateDataPengiriman();
            _buildPopupDialog(context);
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
                textAlign: (TextAlign.center),
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
                      "Pengiriman Request",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data Berhasil di Kirim ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Yeay,Berhasil Di Kirim",
              style: TextStyle(
                  color: Colors.lightGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
              "Data sudah di Kirim",
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
                        MaterialPageRoute(builder: (context) => Pengiriman()),
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
                    width: 160,
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
                    width: 80,
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
                                  primary: list[i]['status_desc'] == 'Alokasi'
                                      ? Colors.orangeAccent
                                      : Colors.blue,
                                  minimumSize: Size(70, 1),
                                  padding: EdgeInsets.all(1.0),
                                ),
                                child: Container(
                                  child: Text(
                                    list[i]['status_desc'],
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
