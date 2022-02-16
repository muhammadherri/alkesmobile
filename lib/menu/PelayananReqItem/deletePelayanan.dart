import 'dart:convert';
import 'package:alkes/menu/PelayananReqItem/detailPelayananRequest.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alkes/main.dart';

class DeletePelayanan extends StatefulWidget {
  final List list;
  final int index;
  final Request;

  DeletePelayanan({Key key, this.Request, this.index, this.list})
      : super(key: key);
  @override
  _DeletePelayananState createState() => _DeletePelayananState(
        request_id: this.list[this.index]["request_id"].toString(),
      );
}

class _DeletePelayananState extends State<DeletePelayanan> {
  final String request_id;
  String RequestID = "";
  String LT_Number = "";
  _DeletePelayananState({this.request_id});

  bool _isVisible = true;
  TextEditingController ItemNumber = TextEditingController();
  TextEditingController lotnum = TextEditingController();
  TextEditingController RequestId = TextEditingController();
  TextEditingController namaproduk = TextEditingController();

  @override
  void initState() {
    _isVisible = !_isVisible;
    super.initState();
    RequestId.text = widget.list[widget.index]['request_id'].toString();
    ItemNumber.text = widget.list[widget.index]['item_number'];
    lotnum.text = widget.list[widget.index]['lot_number'];
    namaproduk.text = widget.list[widget.index]['item_desc'];
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
  }

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

    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailPelayananRequest(
                Request: Request,
              )),
    );
  }

  var Request;
  String message;
  Future deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("RequestID", RequestId.text);
    await prefs.setString("LT_Number", lotnum.text);
    setState(() {
      RequestID = prefs.getString("RequestID");
      print('counter value : $RequestID');
      LT_Number = prefs.getString("LT_Number");
      print('counter value : $LT_Number');
    });
    var url =
        "$base/index.php?r=api/deletelot&request_id=$RequestID&lot_number=$LT_Number";
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
    return Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Color(0xFFFF0000),
            centerTitle: true,
            title: new Text(
              'Hapus Item Pelayanan',
              style: TextStyle(
                color: Colors.white,
              ),
            )),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/logos/phaprospattern.png"),
                    fit: BoxFit.cover)),
            child: ListView(
              children: [
                Padding(padding: new EdgeInsets.only(top: 10.0)),
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
                              'Detail Item',
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
                                                    height: 30,
                                                    child: Text("Item Number",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 140,
                                                    height: 30,
                                                    child: Text(ItemNumber.text,
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
                                                    child: Text("Lot Number",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 150,
                                                    height: 30,
                                                    child: Text(
                                                        lotnum.text == ''
                                                            ? 'Not Set'
                                                            : lotnum.text,
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
                                                    child: Text("Item",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    width: 150,
                                                    height: 30,
                                                    child: Text(
                                                        namaproduk.text,
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
              ],
            )),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFFF0000),
          label: const Text(
            'Hapus',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            deleteItem();

            Alert(context);
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

  _message(context) {
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
                      "Add Item",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child:
                    Text("Menambahkan Item", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Text(
              "$message",
              textAlign: (TextAlign.center),
              style: TextStyle(
                  color:
                      "$message" == 'success' ? Colors.lightGreen : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
