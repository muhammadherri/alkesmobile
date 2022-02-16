import 'dart:convert';
import 'package:alkes/menu/tools/date.dart';
import 'package:alkes/menu/Request/dataStok.dart';
import 'package:alkes/menu/Request/detailRequest.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:alkes/main.dart';

class RequestItem extends StatefulWidget {
  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  String selectedrequestfrom;
  List data = [];

  Future getAllName() async {
    var response = await http
        .get("$base/index.php?r=api/list&model=cabang&userid=$userid");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);

    setState(() {
      data = jsonData;
    });
    print(jsonData);
    return response;
  }

  String selectedrequestto;
  List dataReqto = [];

  Future getAllNamePaket() async {
    var response = await http
        .get("$base/index.php?r=api/list&model=cabangtujuan&userid=$userid");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);

    setState(() {
      dataReqto = jsonData;
    });
    print(jsonData);
    return response;
  }

  TextEditingController rqAddrs = new TextEditingController();
  String pinjam_date;
  String pemakai_rs;
  String pemakai_dokter;
  String pemakai_paket;
  String pemakai_cabang;
  String pinjam_by;
  var Request;
  void senData() async {
    final response =
        await http.post("$base/index.php?r=api/create&model=request", body: {
      "Request[request_date]": "$tgl",
      "Request[request_to]": "$selectedrequestto",
      "Request[need_date]": "$tgl2",
      "Request[request_status]": "0",
      "Request[request_address]": rqAddrs.text,
      "Request[request_from]": "$selectedrequestfrom",
      "Request[request_by]": "$userid",
    });
    var jsonrequest = json.decode(response.body);
    setState(() {
      Request = jsonrequest["data"];
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

  final formats = {
    InputType.date: DateFormat('yyyy-MM-dd'),
  };

  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;

  String pilihTanggal, labelText;
  DateTime tgl = new DateTime.now();
  DateTime tgl2 = new DateTime.now();
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);

  Future<Null> _selectedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        pilihTanggal = new DateFormat.yMd().format(tgl);
      });
    } else {}
  }

  Future<Null> _selectedDatePakai(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl2,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (picked != null && picked != tgl2) {
      setState(() {
        tgl2 = picked;
        pilihTanggal = new DateFormat.yMd().format(tgl2);
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    getAllName();
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
                MaterialPageRoute(builder: (context) => Stok()),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Input Request Barang",
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
                    DateDropdown(
                      labelText: "Tgl Request",
                      valueText: new DateFormat.yMd().format(tgl),
                      valueStyle: valueStyle,
                      onPressed: () {
                        _selectedDate(context);
                      },
                    ),

                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedrequestfrom,
                      hint: Text('Cabang'),
                      items: data.map(
                        (list) {
                          return DropdownMenuItem(
                              child: Text(list['cabang_name']),
                              value: list['cabang_id'].toString());
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedrequestfrom = value;
                        });
                      },
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    Center(
                        child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedrequestto,
                      hint: Text('Permintaan Ke'),
                      items: dataReqto.map(
                        (list) {
                          return DropdownMenuItem(
                              child: Text(list['cabang_name']),
                              value: list['cabang_id'].toString());
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedrequestto = value;
                        });
                      },
                    )),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),

                    DateDropdown(
                      labelText: "Tgl Datang",
                      valueText: new DateFormat.yMd().format(tgl2),
                      valueStyle: valueStyle,
                      onPressed: () {
                        _selectedDatePakai(context);
                      },
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    TextField(
                        controller: rqAddrs,
                        decoration: InputDecoration(
                            labelText: "Alamat Permintaan",
                            hintText: "Alamat Permintaan",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
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
            'Selanjutnya',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            senData();
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
                      "Request Item",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data ReqBerhasil Di Tambahkan ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Yeay,Request Di Tambahkan",
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
