import 'dart:convert';
import 'package:alkes/main.dart';
import 'package:alkes/menu/PelayananReqItem/deletePelayanan.dart';
import 'package:alkes/menu/PelayananReqItem/pelayananRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailPelayananRequest extends StatefulWidget {
  final String base;
  final Request;

  DetailPelayananRequest({this.Request, this.base});

  @override
  _DetailPelayananRequestState createState() => _DetailPelayananRequestState(
      request_id: this.Request['request_id'],
      request_date: this.Request['request_date'].toString(),
      request_to: this.Request['request_to'].toString(),
      request_no: this.Request['request_no'].toString(),
      need_date: this.Request['need_date'].toString());
}

class _DetailPelayananRequestState extends State<DetailPelayananRequest> {
  int request_id;
  final String lot_number;
  final String request_date;
  final String request_to;
  final String request_no;
  final String need_date;
  _DetailPelayananRequestState(
      {this.request_date,
      this.request_to,
      this.request_no,
      this.need_date,
      this.request_id,
      this.lot_number});

  TextEditingController namabarang = TextEditingController();
  String RequestID = "";
  TextEditingController RequestId = TextEditingController();

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("RequestID", RequestId.text);
    setState(() {
      RequestID = prefs.getString("RequestID");
      print('counter value : $RequestID');
    });
  }

  Future<List> getSummary() async {
    final response = await http
        .get("$base/index.php?r=api/requestitemsummary&id=$request_id");
    return json.decode(response.body);
  }

  String message;
  String lot_numbers;
  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/requestitem&id=$request_id&status=0"
            );

    return json.decode(response.body);
  }

  void updateDataPelayanan() {
    var url = "$base/index.php?r=api/update&model=request&id=$request_id";
    http.post(url, body: {
      "Request[request_status]": "4",
      "Request[approve_by]": "$userid",
    });
  }
  String code = "";
  String getcode = "";

  Future scanbarcode() async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      namabarang.text = getcode;
    });
    final response = await http
        .post('$base/index.php?r=api/requestaddlot&id=$RequestID', body: {
      "lot_number": namabarang.text,
      "status": "0",
      "mode": "alokasi"
    });
    print('request:$RequestID');
    print('request:$namabarang.text');
    var jsonmessage = json.decode(response.body);
    setState(() {
      message = jsonmessage["message"];
      lot_numbers = jsonmessage["lot_number"].toString();

      print('counter value : $message');
      print('counter value : $lot_numbers');
    });
    _message(context);
  }

  @override
  void initState() {
    super.initState();
    RequestId.text = request_id.toString();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print('$RequestId.text');
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PelayananRequest()),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Detail Pelayanan Barang",
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
                              'Detail Pinjam Request',
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
                                                        "Tanggal Request",
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
                                                        "Tujuan Permintaan",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(request_to,
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
                                                    child: Text("Nomor Req",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(request_no,
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
                                                    height: 14,
                                                    child: Text(need_date,
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
                                            child: Text(
                                                "Daftar Pelayanan Request",
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
                                                  setIntoSharedPreferences(),
                                                  scanbarcode(),
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
                                                          "Daftar Item Summary",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ],
                                                ),
                                                new Padding(
                                                  padding: new EdgeInsets.only(
                                                      top: 10.0),
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      height: 30,
                                                      child: Text("Item",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      width: 60,
                                                      height: 30,
                                                      child: Text("Quantity",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 30,
                                                      child: Text("Qty Alokasi",
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
                                                        future: getSummary(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot.hasError)
                                                            print(
                                                                snapshot.error);
                                                          return snapshot
                                                                  .hasData
                                                              ? new IsiSummary(
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
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
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
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      child: Text("Item",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 155,
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 30,
                                                      child: Text("No Lot",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    Container(
                                                      width: 10,
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      width: 140,
                                                      height: 30,
                                                      child: Text("Action",
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
            'Layani',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            updateDataPelayanan();
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
                      "Pelayanan Request",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child:
                    Text("Berhasil Di Layani", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Yeay,Berhasil Di Layani",
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
              "Berhasil Di Layani",
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
                            builder: (context) => PelayananRequest()),
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
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
}

// ignore: must_be_immutable
class IsiSummary extends StatelessWidget {
  final String message;
  List list;
  IsiSummary({this.list, this.message});
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
                    width: 130,
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
                    width: 30,
                    height: 30,
                  ),
                  Container(
                    width: 30,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(list[i]['request_qty'].toString(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 30,
                  ),
                  Container(
                    width: 30,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(list[i]['alokasi_qty'].toString(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))),
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

class IsiDetail extends StatefulWidget {
  final String message;
  List list;
  IsiDetail({this.list, this.message});

  @override
  _IsiDetailState createState() => _IsiDetailState();
}

class _IsiDetailState extends State<IsiDetail> {
  var Request;

  List list;
  TextEditingController Lot_Number = TextEditingController();
  String RequestID = "";
  TextEditingController RequestId = TextEditingController();
  String LT_Number = "";
  Future<List> getData() async {
    final response = await http.get(
        "$base/index.php?r=api/requestitem&id=$RequestID&status=0"
        );

    return json.decode(response.body);
  }

  TextEditingController reqid = new TextEditingController();
  TextEditingController req_date = new TextEditingController();
  TextEditingController req_to = new TextEditingController();
  TextEditingController req_no = new TextEditingController();
  TextEditingController nd_date = new TextEditingController();
  void getDataheader() async {
    final response = await http
        .get("$base/index.php?r=api/view&model=request&id=$RequestID");
    var jsonrequest = json.decode(response.body);
    setState(() {
      Request = jsonrequest["data"];
      reqid.text = Request["request_id"].toString();
      req_date.text = Request["request_date"];
      req_to.text = Request["request_to"];
      req_no.text = Request["request_no"];
      nd_date.text = Request["need_date"];
      print('counter value : $Request');
      print('counter value : $reqid.text');
      print('counter value : $req_date.text');
      print('counter value : $req_to.text');
      print('counter value : $req_no.text');
      print('counter value : $nd_date.text');
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailPelayananRequest(
                Request: Request,
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
    await prefs.setString("RequestID", RequestId.text);
    setState(() {
      RequestID = prefs.getString("RequestID");
      print('counter value : $RequestID');
    });
  }

  Future deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("RequestID", RequestId.text);
    await prefs.setString("LT_Number", Lot_Number.text);
    setState(() {
      RequestID = prefs.getString("RequestID");
      print('counter value : $RequestID');
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
    var url =
        "$base/index.php?r=api/deletelot&request_id=$RequestID&lot_number=$LT_Number";
    http.post(url, body: {
    });

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
          padding: const EdgeInsets.all(5.0),
          child: new GestureDetector(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: 150,
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
                      child: Text(
                        RequestId.text =
                            widget.list[i]['request_id'].toString(),
                        style: TextStyle(fontSize: 0),
                      ),
                    ),
                    Container(
                      width: 15,
                      height: 70,
                    ),
                    Container(
                      width: 80,
                      height: 70,
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                  Lot_Number.text =
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
                            child: ButtonTheme(
                              minWidth: 20.0,
                              height: 20.0,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                    primary: widget.list[i]['status'] == 0
                                        ? Colors.green
                                        : Colors.blueAccent,
                                    minimumSize: Size(70, 1),
                                    padding: EdgeInsets.all(1.0)),
                                child: Container(
                                  child: Text(
                                      widget.list[i]['status'] == 0
                                          ? 'Alokasi'
                                          : 'Dikirim',
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
                                            DetailPelayananRequest()),
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DeletePelayanan(
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
