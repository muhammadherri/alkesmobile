import 'dart:convert';
import 'package:alkes/menu/Pengiriman/detailPengiriman.dart';
import 'package:alkes/menu/Pengiriman/pengiriman.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alkes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDataPengiriman extends StatefulWidget {
  final Request;
  final String base;
  UpdateDataPengiriman({this.Request,this.base});
  @override
  _UpdateDataPengirimanState createState() => _UpdateDataPengirimanState(
    request_id: this.Request['request_id'].toString()
  );
}

class _UpdateDataPengirimanState extends State<UpdateDataPengiriman> {
  final String request_id;
  _UpdateDataPengirimanState({this.request_id});
  
  TextEditingController alamatReq;
  TextEditingController noSuratJln;
  TextEditingController noResi;
  TextEditingController eksp;
  var Request;
  String RequestID = "";
  
  void updateData()async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
    final response = await http.post("$base/index.php?r=api/update&model=request&id=$request_id", body: {
      "Request[request_address]": alamatReq.text,
      "Request[no_resi]": noResi.text,
      "Request[ekspedisi]": eksp.text,
      "Request[request_status]": "5",

    });
     var jsonpemakai = json.decode(response.body);
    setState(() {
      Request = jsonpemakai["data"];
      print('counter value : $Request');
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailPengiriman(
                Request: Request,
              )),
    );
  }

 
  @override
  void initState() {
    alamatReq= new TextEditingController(text: widget.Request['request_address']);
    noSuratJln= new TextEditingController(text: widget.Request['surat_jalan_no']);
    noResi= new TextEditingController(text: widget.Request['no_resi']);
    eksp= new TextEditingController(text: widget.Request['ekspedisi']);
    super.initState();  
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
            "Tambah Alamat Pengiriman",
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
                Column(
                  children: [
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                   
                    TextField(
                        controller: alamatReq,
                        decoration: InputDecoration(
                            labelText: "Alamat Request",
                            hintText: "Alamat Request",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    TextField(
                        controller: noResi,
                        decoration: InputDecoration(
                            labelText: "No Resi",
                            hintText: "No Resi",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    TextField(
                        controller: eksp,
                        decoration: InputDecoration(
                            labelText: "Ekspedisi",
                            hintText: "Ekspedisi",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Color(0xFFc7f2e9),
          label: const Text(
            'Tambahkan',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            updateData();
            print('Request:${alamatReq.text}');
            print('Request:${noResi.text}');
            print('Request:${eksp.text}');
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
                      "Alamat Pengiriman",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Berhasil Di Tambahkan ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Yeay,Berhasil Di Tambahkan",
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
              "Data Sudah Di Tambahkan",
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
                          MaterialPageRoute(builder: (context) => Pengiriman()),
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
