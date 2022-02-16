import 'dart:convert';
import 'package:alkes/main.dart';
import 'package:alkes/menu/PinjamItem/inputPinjamItem.dart';
import 'package:alkes/menu/PinjamItem/isiDetailPinjamItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../homeScreen2.dart';

class ListPinjamItem extends StatefulWidget {
  @override
  _ListPinjamItemState createState() => _ListPinjamItemState();
}

class _ListPinjamItemState extends State<ListPinjamItem> {
  Future<List> getData() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid");
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
          "Peminjaman Barang",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPinjamItem()),
          );
        },
        child: Icon(Icons.add, color: Colors.teal),
        backgroundColor: Color(0xFFc7f2e9),
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  String pinjam_date = "";
  String pemakai_cabang = "";
  String pemakai_no = "";
  String pemakai_rs = "";
  String pemakai_dokter = "";
  String paket_name = "";

  TextEditingController PID = TextEditingController();
  TextEditingController TglPinjam = TextEditingController();
  TextEditingController Pemohon = TextEditingController();
  TextEditingController NoPinjam = TextEditingController();
  TextEditingController RS = TextEditingController();
  TextEditingController NDokter = TextEditingController();
  TextEditingController POperasi = TextEditingController();

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
                  new Padding(
                    padding: new EdgeInsets.only(top: 10.0),
                  ),
                  Row(
                    children: [
                      Container(
                        child: Text(
                          'Peminjaman Item',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 58.0),
                      ),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: list[i]['pemakai_status'] == 0
                              ? Colors.yellow
                              : list[i]['pemakai_status'] == 1
                                  ? Colors.blue
                                  : Colors.green,
                          minimumSize: Size(88, 1),
                          padding: EdgeInsets.all(1.0),
                        ),
                        // color:
                        onPressed: () {},
                        child: Text(
                          list[i]['status_name'],
                          style: TextStyle(
                              color: list[i]['pemakai_status'] == 0
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(Pemohon.text=list[i]['pemakai_cabang'],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            Container(
                              width: 50,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(POperasi.text=list[i]['paket_name'].toString(),
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                            ),
                            Container(
                              width: 70,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(NDokter.text=list[i]['pemakai_dokter'],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 15,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(TglPinjam.text=list[i]['pinjam_date'],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Container(
                              width: 0,
                              height: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(NoPinjam.text=list[i]['pemakai_no'],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                            Container(
                              width: 70,
                              height: 15,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(RS.text=list[i]['pemakai_rs'],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                            ),
                            Container(
                              width: 50,
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        "pinjam_date", TglPinjam.text);
                                    await prefs.setString(
                                        "pemakai_cabang", Pemohon.text);
                                    await prefs.setString(
                                        "pemakai_no", NoPinjam.text);
                                    await prefs.setString(
                                        "pemakai_rs", RS.text);
                                    await prefs.setString(
                                        "pemakai_dokter", NDokter.text);
                                    await prefs.setString(
                                        "paket_name", POperasi.text);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              IsiDetailPinjamItem(
                                                Pinjam: list[i],
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
                ],
              ),
            )
                ),
          ),
        );
      },
    );
  }
}
