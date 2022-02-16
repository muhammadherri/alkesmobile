import 'dart:convert';
import 'package:alkes/menu/Request/detailRequest.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alkes/main.dart';

class UpdateDataRequest extends StatefulWidget {
  final List list;
  final int index;
  final Request;

  UpdateDataRequest({Key key, this.Request, this.index, this.list})
      : super(key: key);
  @override
  _UpdateDataRequestState createState() => _UpdateDataRequestState(
        request_id: this.list[this.index]["request_id"].toString(),
      );
}

class _UpdateDataRequestState extends State<UpdateDataRequest> {
  final String request_id;
  String RequestID = "";
  _UpdateDataRequestState({this.request_id});

  bool _isVisible = true;
  TextEditingController ItemNumber = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController jumlah = TextEditingController();
  TextEditingController RequestId = TextEditingController();
  TextEditingController Stock = TextEditingController();

  @override
  void initState() {
    _isVisible = !_isVisible;
    super.initState();
    RequestId.text = widget.list[widget.index]['request_id'].toString();
    ItemNumber.text = widget.list[widget.index]['item_number'];
    desc.text = widget.list[widget.index]['item_desc'];
    Stock.text = widget.list[widget.index]['stock'];
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
  }

  var Request;
  String message;
  void senData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
    final response = await http
        .post("$base/index.php?r=api/create&model=requestitem", body: {
      "Requestitem[request_id]": "$RequestID",
      "Requestitem[item_number]": ItemNumber.text,
      "Requestitem[request_qty]": jumlah.text,
    });
    print('request_id:${"$RequestID"}');
    print('item_number:${ItemNumber.text}');
    print('request_qty:${jumlah.text}');
    var jsonmessage = json.decode(response.body);
    setState(() {
      message = jsonmessage["message"];
      print('counter value : $message');
    });
    _message(context);

    final responses = await http
        .get("$base/index.php?r=api/view&id=$RequestID&model=request");
    var decoderesponses = json.decode(responses.body);
    setState(() {
      Request = decoderesponses["data"];
      print('counter value : $Request');
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailRequestItem(
                Request: Request,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Colors.green,
            ),
            backgroundColor: Color(0xFFc7f2e9),
            centerTitle: true,
            title: new Text(
              'Tambah Data Permintaan',
              style: TextStyle(
                color: Colors.green,
              ),
            )),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/logos/phaprospattern.png"),
                  fit: BoxFit.cover)),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  Column(
                    children: [
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
                      ),
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
                      ),
                      TextField(
                          readOnly: true,
                          controller: ItemNumber,
                          decoration: InputDecoration(
                              labelText: 'Item Number',
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
                      ),
                      TextField(
                          readOnly: true,
                          controller: Stock,
                          decoration: InputDecoration(
                              labelText: 'Stock Tersedia',
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
                      ),
                      TextField(
                          maxLines: 3,
                          readOnly: true,
                          controller: desc,
                          decoration: InputDecoration(
                              labelText: 'Item Descripsi',
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
                      ),
                      TextField(
                          onChanged: (value) {
                            if (value == "0")
                              jumlah.text = jumlah.text
                                  .substring(0, jumlah.text.length - 1);
                            if (value.length > 0) {
                              int data = int.tryParse(
                                  value.substring(value.length - 1));
                              if (data == null) {
                                print(data);
                                setState(() {
                                  jumlah..text = jumlah.text
                                      .substring(0, jumlah.text.length - 1)
                                        ..selection = TextSelection.collapsed(
                                            offset: jumlah.text.length);
                                });
                              }
                            }
                          },
                          controller: jumlah,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: "Jumlah Diminta",
                              hintText: "Jumlah Diminta",
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                    ],
                  )
                ],
              )),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFc7f2e9),
          label: const Text(
            'Request',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            senData();
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
