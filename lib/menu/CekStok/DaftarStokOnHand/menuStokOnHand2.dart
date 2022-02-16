import 'dart:convert';
import 'package:alkes/main.dart';
import 'package:alkes/menu/CekStok/DaftarStokOnHand/menuStokOnHand.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class menuStokOnHand2 extends StatefulWidget {
  final String base;
  menuStokOnHand2({this.base});
  @override
  _menuStokOnHand2State createState() => _menuStokOnHand2State(

      );
}

class _menuStokOnHand2State extends State<menuStokOnHand2> {
  var ItemNumber = new TextEditingController();
  var ItemName = new TextEditingController();
  String item_number;
  String item_name;
  String selectedNamePaket;
  List dataPaket = [];

  Future getAllNamePaket() async {
    get();
    var response = await http.get("$base/index.php?r=api/list&model=paket");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);
    setState(() {
      dataPaket = jsonData;
    });
    print(jsonData);
    return response;
  }

  void get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      item_number = prefs.getString("item_number");
      item_name = prefs.getString("item_name");
      selectedNamePaket = prefs.getString("selectedNamePaket");
    });
  }

  Future<List> getData() async {
    final response = await http.get(
        "$base/index.php?r=api/stock&userid=$userid&item_number=$item_number&item_name=$item_name&paket=$selectedNamePaket");
    print(
        '$base/index.php?r=api/stock&userid=$userid&item_number=$item_number&item_name=$item_name&paket=$selectedNamePaket');

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    item_number = "$ItemNumber";
    item_name = "$ItemName";
    getAllNamePaket();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_sharp, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => menuStokOnHand()),
              );
            },
          ),
          iconTheme: IconThemeData(
            color: Colors.green,
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Daftar Stok On Hand",
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
            child: Builder(builder: (BuildContext context) {
              return OfflineBuilder(
                connectivityBuilder: (BuildContext context,
                    ConnectivityResult connectivity, Widget child) {
                  final bool connected =
                      connectivity != ConnectivityResult.none;
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                                    Container(
                                      child: TextField(
                                          controller: ItemNumber,
                                          decoration: InputDecoration(
                                              labelText: "Item Number",
                                              hintText: "Item Number",
                                              border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          20.0)))),
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 5.0),
                                    ),
                                    TextField(
                                        controller: ItemName,
                                        decoration: InputDecoration(
                                            labelText: "Item Name",
                                            hintText: "Item Name",
                                            border: new OutlineInputBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        20.0)))),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 5.0),
                                    ),
                                    Center(
                                        child: DropdownButtonFormField(
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        border: const OutlineInputBorder(),
                                      ),
                                      value: selectedNamePaket,
                                      hint: Text('Filter by Paket'),
                                      items: dataPaket.map(
                                        (list) {
                                          return DropdownMenuItem(
                                              child: Text(list['paket_name']),
                                              value:
                                                  list['paket_id'].toString());
                                        },
                                      ).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedNamePaket = value;
                                        });
                                      },
                                    )),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 10.0),
                                    ),
                                  ]))),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 165,
                                                              height: 30,
                                                              child: Text(
                                                                  "Item",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            Container(
                                                              width: 10,
                                                              height: 10,
                                                              child: Text("",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            Container(
                                                              width: 80,
                                                              height: 30,
                                                              child: Text(
                                                                  "Nama Paket",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            Container(
                                                              width: 10,
                                                              height: 30,
                                                              child: Text("",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            Container(
                                                              width: 50,
                                                              height: 30,
                                                              child: Text(
                                                                  "Stock",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 300,
                                                              height: 555,
                                                              child:
                                                                  FutureBuilder<
                                                                      List>(
                                                                future:
                                                                    getData(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                      .hasError)
                                                                    print(snapshot
                                                                        .error);
                                                                  return snapshot
                                                                          .hasData
                                                                      ? new IsiDetail(
                                                                          list:
                                                                              snapshot.data,
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
                                  ])))
                    ],
                  ),
                ),
              );
            })),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFc7f2e9),
          label: Row(
            children: [
              const Text(
                'Cari',
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.search,
                color: Colors.green,
              )
            ],
          ),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("item_number", ItemNumber.text);
            await prefs.setString("item_name", ItemName.text);
            await prefs.setString("selectedNamePaket", selectedNamePaket);
            setState(() {
              item_number = prefs.getString("item_number");
              item_name = prefs.getString("item_name");
            });
            getData();
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
}

class IsiDetail extends StatefulWidget {
  List list;
  IsiDetail({this.list});

  @override
  _IsiDetailState createState() => _IsiDetailState();
}

class _IsiDetailState extends State<IsiDetail> {
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
                    width: 10,
                    height: 70,
                  ),
                  Container(
                    width: 60,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(widget.list[i]['paket_name'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))),
                      ],
                    ),
                  ),

                  Container(
                    width: 10,
                    height: 70,
                  ),
                  Container(
                    width: 90,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(widget.list[i]['stock'].toString(),
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
