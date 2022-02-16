import 'dart:convert';
import 'package:alkes/main.dart';
import 'package:alkes/menu/Request/updateDataRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddItemBaru extends StatefulWidget {
  final String base;
  AddItemBaru({this.base});
  @override
  _AddItemBaruState createState() => _AddItemBaruState(
        paket_id: ['paket_id'].toString(),
      );
}

class _AddItemBaruState extends State<AddItemBaru> {
  var ItemNumber = new TextEditingController();
  var ItemName = new TextEditingController();
  List MyList;
  ScrollController _scrollController = new ScrollController();
  int _currentMax = 10;
  _AddItemBaruState({this.paket_id});
  final String paket_id;
  String selectedNamePaket;
  List dataPaket = [];
  String item_number;
  String item_name;
  Future getAllNamePaket() async {
    getFromSharedPreferences();
    var response = await http.get("$base/index.php?r=api/list&model=paket");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);
    setState(() {
      dataPaket = jsonData;
    });
    print(jsonData);
    return response;
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
      item_number = prefs.getString("item_number");
      item_name = prefs.getString("item_name");
      selectedNamePaket = prefs.getString("selectedNamePaket");
    });
  }

  String RequestID;
  Future<List> getData() async {
    final response = await http.get(
        "$base/index.php?r=api/stock&userid=$userid&paket=$selectedNamePaket&requestid=$RequestID&item_number=$item_number&item_name=$item_name");
    print(
        "$base/index.php?r=api/stock&userid=$userid&paket=$selectedNamePaket&requestid=$RequestID&item_number=$item_number&item_name=$item_name");
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    MyList = List.generate(
        10,
        (item_number) =>
            "Item:$base/index.php?r=api/stock&userid=$userid&paket=$selectedNamePaket&requestid=$RequestID");
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getData();
      }
    });
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
        iconTheme: IconThemeData(
          color: Colors.green,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFc7f2e9),
        title: Text(
          "Tambah Item Permintaan",
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
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
                                        new BorderRadius.circular(20.0)))),
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
                                      new BorderRadius.circular(20.0)))),
                      new Padding(
                        padding: new EdgeInsets.only(top: 20.0),
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
                                value: list['paket_id'].toString());
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedNamePaket = value;
                          });
                        },
                      )),
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.only(top: 10.0),
              ),
              Card(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                width: 140,
                                                height: 30,
                                                child: Text("Item",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                width: 5,
                                                height: 30,
                                                child: Text("",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                child: Text("Paket",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                child: Text("",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                child: Text("Stock",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 300,
                                                height: 555,
                                                child: FutureBuilder<List>(
                                                  future: getData(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError)
                                                      print(snapshot.error);
                                                    return snapshot.hasData
                                                        ? new IsiDetail(
                                                            list: snapshot.data,
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
            ],
          ),
        ),
      ),
      
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
        )
    );
  }
}
class IsiDetail extends StatefulWidget {
  List list;
  IsiDetail({this.list});

  @override
  _IsiDetailState createState() => _IsiDetailState();
}

class _IsiDetailState extends State<IsiDetail> {
  ScrollController _scrollController = new ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      controller: _scrollController,
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
                    width: 135,
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
                    width: 5,
                    height: 20,
                  ),
                  Container(
                    width: 40,
                    height: 70,
                    child: Text(widget.list[i]['paket_name'],
                        style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    width: 50,
                    height: 70,
                  ),
                  Container(
                    width: 50,
                    height: 70,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(widget.list[i]['stock'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))),
                      ],
                    ),
                  ),
                  Container(
                    width: 5,
                    height: 70,
                  ),
                  Container(
                    width: 5,
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
                                  builder: (BuildContext context) =>
                                      UpdateDataRequest(
                                        list: widget.list,
                                        index: i,
                                      )),
                            );
                          },
                          child: Align(
                              alignment: Alignment.center,
                              child: Text('Pilih',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold))),
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
