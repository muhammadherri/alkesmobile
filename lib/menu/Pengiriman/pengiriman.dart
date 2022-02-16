import 'dart:convert';
import 'package:alkes/menu/Pengiriman/detailPengiriman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import '../../homeScreen2.dart';
import 'package:alkes/main.dart';

class Pengiriman extends StatefulWidget {
  final String base;
  Pengiriman({this.base});
  @override
  _PengirimanState createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman> {
  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=request&mode=4&userid=$userid");
    return json.decode(response.body);
  }

  @override
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
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFc7f2e9),
        title: Text(
          "Pengiriman Barang",
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
        child: Builder(
          builder: (BuildContext context) {
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
              child: FutureBuilder<List>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? new ItemList(
                          list: snapshot.data,
                        )
                      : new Center(
                          child: new CircularProgressIndicator(),
                        );
                },
              ),
            );
          },
        ),
      ),
     );
  }
}

class ItemList extends StatelessWidget {
  List list;
  ItemList({this.list});
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return new Container(
          padding: const EdgeInsets.all(5.0),
          child: new GestureDetector(
            child: new Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                          child: Text(
                            'Pengiriman',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0),
                        ),
                        ButtonTheme(
                          minWidth: 88.0,
                          height: 15.0,
                          child: TextButton(
                            style: ElevatedButton.styleFrom(
                              primary: list[i]['request_status'] == 5
                                  ? Colors.blue
                                      : Colors.green,
                              minimumSize: Size(88, 1),
                              padding: EdgeInsets.all(1.0),
                            ),

                            onPressed: () {},
                            child: Text(
                              list[i]['status_name'] ,
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 12),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 15,
                          child: Text(list[i]['request_from'],
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 180,
                          height: 50,
                          child: Text(list[i]['request_no'],
                              style: TextStyle(fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        ),
                        Column(
                          children: [
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                minimumSize: Size(88, 20),
                                padding: EdgeInsets.all(12.0),
                                elevation: 5,
                              ),
                              child: Container(
                                child: Text(
                                  'Detail',
                                  style: TextStyle(fontSize: 12.0,color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPengiriman(
                                            Request: list[i],
                                          )),
                                );
                              },
                            )
                          ],
                        ),
                      ],
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
