import 'dart:convert';
import 'package:alkes/main.dart';
import 'package:alkes/menu/CekStok/cekStok.dart';
import 'package:alkes/menu/CekStok/stokNasional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchStokNasional extends StatefulWidget {
  final String base;
  SearchStokNasional({this.base});
  @override
  _menuStokOnHand2State createState() => _menuStokOnHand2State(

      );
}

class _menuStokOnHand2State extends State<SearchStokNasional> {
  TextEditingController ItemNumber = new TextEditingController();
  TextEditingController ItemName = new TextEditingController();

  String selectedNamePaket;
  List dataPaket = [];

  Future getAllNamePaket() async {
    var response = await http
        .get("$base/index.php?r=api/list&model=cabangtujuan&userid=$userid");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);
    setState(() {
      dataPaket = jsonData;
    });
    print(jsonData);
    return response;
  }

  void set() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("item_number", ItemNumber.text);
    await prefs.setString("item_name", ItemName.text);
    await prefs.setString("selectedNamePaket", selectedNamePaket);
  }

  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/stock&cabangid=$selectedNamePaket");
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
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
              MaterialPageRoute(builder: (context) => CekStok()),
            );
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.green,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFc7f2e9),
        title: Text(
          "Search Stok Nasional",
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
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        new Padding(
                          padding: new EdgeInsets.only(top: 10.0),
                        ),
                        TextField(
                            controller: ItemNumber,
                            decoration: InputDecoration(
                                labelText: "Item Number",
                                hintText: "Item Number",
                                border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0)))),
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
                          padding: new EdgeInsets.only(top: 5.0),
                        ),
                        Center(
                            child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: const OutlineInputBorder(),
                          ),
                          value: selectedNamePaket,
                          hint: Text('Filter by Cabang'),
                          items: dataPaket.map(
                            (list) {
                              return DropdownMenuItem(
                                  child: Text(list['cabang_name']),
                                  value: list['cabang_id'].toString());
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
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: double.infinity,
                          child: TextButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFFc7f2e9),
                                elevation: 5,
                                padding: EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                            onPressed: () {
                              set();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StokNasional(),
                                ),
                              );
                            },
                            child: Text(
                              'CARI',
                              style: TextStyle(
                                color: Colors.green,
                                letterSpacing: 1.5,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          })),
    );
  }
}
