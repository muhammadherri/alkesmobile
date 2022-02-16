import 'dart:convert';
import 'package:alkes/menu/tools/date.dart';
import 'package:alkes/menu/PinjamItem/isiDetailPinjamItem.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'listPinjamItem.dart';
import 'package:alkes/main.dart';

class InputPinjamItem extends StatefulWidget {
  @override
  _InputPinjamItemState createState() => _InputPinjamItemState();
}

class _InputPinjamItemState extends State<InputPinjamItem> {
  String selectedNamePaket;
  List dataPaket = [];

  Future getAllNamePaket() async {
    var response = await http.get("$base/index.php?r=api/list&model=paket");
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);

    setState(() {
      dataPaket = jsonData;
    });
    print(jsonData);
    return response;
  }

  String selectedName;
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

  TextEditingController rumahSakit = new TextEditingController();
  TextEditingController namaDokter = new TextEditingController();
  var Pinjam;
  void senData() async {
    final response =
        await http.post("$base/index.php?r=api/create&model=pemakai", body: {
      "Pemakai[pemakai_date]": "$tgl",
      "Pemakai[pemakai_rs]": rumahSakit.text,
      "Pemakai[pemakai_dokter]": namaDokter.text,
      "Pemakai[pemakai_paket]": "$selectedNamePaket",
      "Pemakai[pemakai_cabang]": "$selectedName",
      "Pemakai[pinjam_by]": "$userid",
    });
    var jsonpemakai = json.decode(response.body);
    setState(() {
      Pinjam = jsonpemakai["data"];
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
                MaterialPageRoute(builder: (context) => ListPinjamItem()),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFc7f2e9),
          title: Text(
            "Input Peminjaman Barang",
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
                      labelText: "Tgl Kebutuhan",
                      valueText: new DateFormat.yMd().format(tgl),
                      valueStyle: valueStyle,
                      onPressed: () {
                        _selectedDate(context);
                      },
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    TextField(
                        controller: rumahSakit,
                        decoration: InputDecoration(
                            labelText: "Rumah Sakit",
                            hintText: "Rumah Sakit",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    TextField(
                        controller: namaDokter,
                        decoration: InputDecoration(
                            labelText: "Nama Dokter",
                            hintText: "Nama Dokter",
                            border: new OutlineInputBorder(
                                borderRadius:
                                    new BorderRadius.circular(20.0)))),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedName,
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
                          selectedName = value;
                        });
                      },
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(top: 20.0),
                    ),
                    Center(
                        child: DropdownButtonFormField(
                      isExpanded: true,
                      value: selectedNamePaket,
                      hint: Text('Paket Operasi'),
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
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
                      "Pinjam Item",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data Berhasil Di Tambahkan ",
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
