import 'dart:convert';
import 'package:alkes/menu/Approval/rejectRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:alkes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'approvalRequest.dart';

class DetailApproval extends StatefulWidget {
  DetailApproval({this.index, this.list});
  List list;
  int index;
  @override
  _DetailApprovalState createState() => _DetailApprovalState(
      request_id: this.list[this.index]['request_id'].toString());
}

class _DetailApprovalState extends State<DetailApproval> {
  final String request_id;
  _DetailApprovalState({this.request_id});
  TextEditingController RequestId = TextEditingController();
  String RequestID = "";

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("RequestID", RequestId.text);
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/requestitemsummary&id=$request_id");
    return json.decode(response.body);
  }

  void updateDataApprove() {
    var url = "$base/index.php?r=api/update&model=request&id=$request_id";
    http.post(url, body: {
      "Request[request_status]": "2",
      "Request[approve_by]": "$userid",
    });
  }

  void updateDataReject() {
    var url = "$base/index.php?r=api/update&model=request&id=$request_id";
    http.post(url, body: {
      "Request[request_status]": "3",
      "Request[approve_by]": "$userid",
    });
  }

  TextEditingController namabarang = TextEditingController(text: "");

  String code = "";
  String getcode = "";

  Future scanbarcode() async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      namabarang.text = getcode;
    });
  }

  @override
  void initState() {
    super.initState();
    RequestId.text = widget.list[widget.index]['request_id'].toString();
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ApprovalRequest()),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFc7f2e9),
        title: Text(
          " Detail Approval",
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
                            'Detail Approval',
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
                                                  child: Text("Tanggal Approve",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  width: 70,
                                                  height: 14,
                                                  child: Text(
                                                      widget.list[widget.index]
                                                          ['request_date'],
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
                                                  child: Text(
                                                      widget.list[widget.index]
                                                          ['request_to'],
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
                                                  child: Text(
                                                      widget.list[widget.index]
                                                          ['request_no'],
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
                                                    child: Text("Quantity",
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
                                                      future: getData(),
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

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  Column(
                    children: [
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          minimumSize: Size(88, 20),
                          padding: EdgeInsets.all(12.0),
                          elevation: 5,
                        ),
                        child: Container(
                          child: Text(
                            'Reject',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          setIntoSharedPreferences();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RejectRequest()),
                          );
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70.0),
                  ),
                  Column(
                    children: [
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFc7f2e9),
                          minimumSize: Size(88, 20),
                          padding: EdgeInsets.all(12.0),
                          elevation: 5,
                        ),
                        child: Container(
                          child: Text(
                            'Approve',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.green),
                          ),
                        ),
                        onPressed: () {
                          updateDataApprove();

                          _buildPopupDialog(context);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }

  // ignore: unused_element
  void _buildPopupRejectDialog(context) {
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
                      "Reject Request",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.red,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ApprovalRequest()),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data Berhasil di Reject ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Berhasil Di Reject",
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
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
              "Data sudah di Reject",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )),
            new Padding(
              padding: new EdgeInsets.only(top: 40.0),
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
                      "Approval Request",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data Berhasil di Approve ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Yeay,Berhasil Diapprove",
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
              "Data sudah di Approve",
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
                            builder: (context) => ApprovalRequest()),
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

// ignore: must_be_immutable
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
                    width: 100,
                    height: 70,
                  ),
                  Container(
                    width: 50,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(list[i]['request_qty'].toString(),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
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
