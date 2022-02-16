import 'dart:convert';
import 'package:alkes/menu/PinjamItem/isiDetailPinjamItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alkes/main.dart';

class DeletePinjam extends StatefulWidget {
  final List list;
  final int index;
  final Pinjam;

  DeletePinjam({Key key, this.Pinjam, this.index, this.list}) : super(key: key);
  @override
  _DeletePinjamState createState() => _DeletePinjamState(
        pemakai_id: this.list[this.index]["pemakai_id"].toString(),
      );
}

class _DeletePinjamState extends State<DeletePinjam> {
  final String pemakai_id;
  String PemakaiID = "";
  String LT_Number = "";
  _DeletePinjamState({this.pemakai_id});

  bool _isVisible = true;
  TextEditingController ItemNumber = TextEditingController();
  TextEditingController lotnum = TextEditingController();
  TextEditingController PemakaiId = TextEditingController();
  TextEditingController namaproduk = TextEditingController();

  @override
  void initState() {
    _isVisible = !_isVisible;
    super.initState();
    PemakaiId.text = widget.list[widget.index]['pemakai_id'].toString();
    ItemNumber.text = widget.list[widget.index]['item_number'];
    lotnum.text = widget.list[widget.index]['lot_number'];
    namaproduk.text = widget.list[widget.index]['item_desc'];
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PemakaiID = prefs.getString("PemakaiID");
    });
  }

  Future<List> getData() async {
    var uri = "$base/index.php?r=api/pemakaiitem&id=$PemakaiID&status=0";
    final response = await http.get(
        uri
        );
    print('$uri');
    return json.decode(response.body);
  }

  TextEditingController pemid = new TextEditingController();
  TextEditingController pemakai_cabang = new TextEditingController();
  TextEditingController pemakai_no = new TextEditingController();
  TextEditingController pemakai_rs = new TextEditingController();
  TextEditingController pemakai_dokter = new TextEditingController();
  TextEditingController pemakai_paket = new TextEditingController();
  TextEditingController pinjam_date = new TextEditingController();
  void getDataheader() async {
    var uri = "$base/index.php?r=api/view&model=pemakai&id=$PemakaiID";
    final response = await http.get(uri);
    print('$uri');
    var jsonrequest = json.decode(response.body);
    setState(() {
      Pinjam = jsonrequest["data"];
      pemakai_cabang.text = Pinjam["pemakai_cabang"];
      pemakai_no.text = Pinjam["pemakai_no"];
      pemakai_rs.text = Pinjam["pemakai_rs"];
      pemakai_dokter.text = Pinjam["pemakai_dokter"];
      pemakai_paket.text = Pinjam["paket_name"];
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

  var Pinjam;
  String message;
  Future deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", PemakaiId.text);
    await prefs.setString("LT_Number", lotnum.text);
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
    return Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Color(0xFFFF0000),
            centerTitle: true,
            title: new Text(
              'Hapus Item Piminjaman',
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
                                                    child: Text(namaproduk.text,
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
          onPressed: () async {
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
