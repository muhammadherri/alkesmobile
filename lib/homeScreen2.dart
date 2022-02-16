import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:alkes/menu/PemakaianItem/datalocal.dart';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alkes/drawer.dart';
import 'package:alkes/menu/Approval/approvalRequest.dart';
import 'package:alkes/menu/CekStok/cekStok.dart';
import 'package:alkes/menu/PelayananReqItem/pelayananRequest.dart';
import 'package:alkes/menu/Penerimaan/penerimaan.dart';
import 'package:alkes/menu/Pengiriman/pengiriman.dart';
import 'package:alkes/menu/PinjamItem/listPinjamItem.dart';
import 'package:alkes/menu/Request/dataStok.dart';
import 'package:badges/badges.dart';
import 'package:flutter/services.dart';
import 'package:alkes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String jmlh;
  String jmlhke2;
  String jmlapi2;
  var jumlah = new TextEditingController();
  var jumlahke2 = new TextEditingController();
  String test;

  var jml = TextEditingController();
  Future<List> getListPinjam() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid");
    return json.decode(response.body);
  }

   Future apijumlah() async {
    final response =
        await http.get("$base/index.php?r=api/jumlahpinjam&userid=$userid");
    var datajumlah = json.decode(response.body);
    setState(() {
      jmlapi2 = datajumlah["jumlah"];
    });
    print('nilai apijumlah :$jmlapi2');
    return datajumlah;
  }

  Future<List> getListPengembalian() async {
    final response = await http
        .get("$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid");
    return json.decode(response.body);
  }

  String listpemakaian;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  var _pemakaian = Pemakaian();
  var _pemakaianService = Pemakaian_Item_Service();
  var pemakaian;
  int id;
  var _pemakaian_item = Pemakaian_item();
  var _pemakaian_item_service = Pemakaian_Item_Service();

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
                        "SYNC TO SERVER",
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
                child: Text('SYNC Berhasil', textAlign: (TextAlign.center)),
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

  Alertmenupemakaian(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
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
                        "Menu Pemakaian",
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
                child:
                    Text('Mohon Untuk Menunggu', textAlign: (TextAlign.center)),
              ),
              new Padding(
                padding: new EdgeInsets.only(top: 20.0),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 5), child: Text("Loading")),
                ],
              ),
              Divider(),
            ],
          );
        });
  }

  Future<String> uploadImage(filepath, url) async {
    final request = http.MultipartRequest('POST', (url));
    request.files.add(http.MultipartFile('Pemakai[bast]',
        File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
        filename: filepath.split("/").last));
    var res = await request.send();
  }

  Future jumlahsync() async {
    var listpemakaikedua = await _pemakaianService.readPemakaikedua();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("jmlh", jumlah.text);
    setState(() {
      jmlh = listpemakaikedua[0]['jml'].toString();
    });

    print('Nilah Jumlh$jmlh');
    return listpemakaikedua;
  }

  Future jumlahsyncstatussatu() async {
    var listpemakaiketiga = await _pemakaianService.readPemakaiketiga();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("jmlhke2", jumlahke2.text);
    setState(() {
      jmlhke2 = listpemakaiketiga[0]['jml'].toString();
    });

    print('Nilah Jumlh:$jmlhke2');
    print('Nilah Jumlh api :$jmlapi');
    return listpemakaiketiga;
  }

  File file;
  Future synctoserver() async {
    var listpemakai = await _pemakaianService.readPemakai();
    listpemakai.forEach((pakai) async {
      if (pakai["pemakai_status"] == 2) {
        var PemakaiId = pakai["pemakai_id"];
        var namafile = pakai['pemakai_bast'];
        var status = pakai['pemakai_status'];
        var listPemakaiItem = await _pemakaian_item_service
            .read_Pemakaian_ItemByPemakaiID(PemakaiId);

        print('$listPemakaiItem["status"]');

        listPemakaiItem.forEach((item) {
          if (item['status'] == 2) {
            var itemNumber = item["item_number"];
            var lotNumber = item["lot_number"];
            var statuspemakaianitem = item["status"];
            var url =
                "$base/index.php?r=api/update&model=pemakaiitem&id=$PemakaiId";
            http.post(url, body: {
              "item_number": '$itemNumber',
              "Pemakaiitem[lot_number]": '$lotNumber',
              "Pemakaiitem[status]": '$statuspemakaianitem',
            });
            print('Upload pemakaian item');
            print('item number:$itemNumber');
            print('lot number :$lotNumber');
            print('status :$statuspemakaianitem');
          }
        });
        print('$PemakaiId');
        var bastfile =
            '/storage/emulated/0/Android/data/com.phapros.alkes/files/Pictures/$namafile';
        final url = Uri.parse(
            "$base/index.php?r=api/update&model=pemakai&id=$PemakaiId");
        uploadImage(bastfile, url);
        var request = http.MultipartRequest('POST', url);
        request.fields["Pemakai[pemakai_status]"] = '$status';
        request.fields["Pemakai[teknisi]"] = pakai["teknisi"];
        print('hasilfile : $bastfile');
        print('Upload Pemakai');
        print('sttus pemakai : $PemakaiId ');
        print('status :$status');
        print('namafile : $namafile ');
        print('status :$pakai["teknisi"]');

        var pic = http.MultipartFile.fromPath("bast", '$bastfile');
        var response = request.send();
      }
    });
    _pemakaianService.deletePemakai_status();
    _pemakaian_item_service.Delete_Pemakaian_Item();
    await new Future.delayed(const Duration(seconds: 1));
    final response = await http.get(
        "$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid&pemakai_status=1");
    var listPeminjam = json.decode(response.body);
    listPeminjam.forEach((pinjam) {
      syncPemakai(pinjam);
    });
    // downloaddata();
    _pemakaianService.updatesync();
    jumlahsync();
    jumlahsyncstatussatu();
  }

  syncPemakai(pinjam) async {
    _pemakaian.pemakai_id = pinjam['pemakai_id'];
    _pemakaian.pemakai_cabang = pinjam['pemakai_cabang'].toString();
    _pemakaian.pemakai_date = pinjam['pemakai_date'].toString();
    _pemakaian.pemakai_dokter = pinjam['pemakai_dokter'].toString();
    _pemakaian.pemakai_no = pinjam['pemakai_no'].toString();
    _pemakaian.pemakai_rs = pinjam['pemakai_rs'].toString();
    _pemakaian.pemakai_status = pinjam['pemakai_status'];
    _pemakaian.pemakai_paket = pinjam['pemakai_paket'].toString();
    _pemakaian.teknisi = pinjam['teknisi'];
    _pemakaian.paket_name = pinjam['paket_name'];
    _pemakaian.pinjam_date = pinjam['pinjam_date'];
    _pemakaianService.savePemakaian(_pemakaian);
    print('Download Pemakai');
    print('pemakai_id:${_pemakaian.pemakai_id}');
    print('pemakai_cabang:${_pemakaian.pemakai_cabang}');
    print('pemakai_date:${_pemakaian.pemakai_date}');
    print('pemakai_dokter:${_pemakaian.pemakai_dokter}');
    print('pemakai_no:${_pemakaian.pemakai_no}');
    print('pemakai_rs:${_pemakaian.pemakai_rs}');
    print('pemakai_status:${_pemakaian.pemakai_status}');
    print('pemakai_paket:${_pemakaian.pemakai_paket}');
    print('teknisi:${_pemakaian.teknisi}');
    print('paket_name:${_pemakaian.paket_name}');
    print('pinjam_date:${_pemakaian.pinjam_date}');
    var pemakaiId = pinjam['pemakai_id'];

    print("$pemakaiId");
    final response = await http
        .get("$base/index.php?r=api/pemakaiitem&status=1&id=$pemakaiId&sync=1");
    var listPeminjamItem = json.decode(response.body);

    listPeminjamItem.forEach((item) {
      syncPemakaiItem(item);
    });
  }

  syncPemakaiItem(item) async {
    _pemakaian_item.pemakai_id = item['pemakai_id'];
    _pemakaian_item.item_desc = item['item_desc'];
    _pemakaian_item.item_number = item['item_number'];
    _pemakaian_item.item_satuan = item['item_satuan'];
    _pemakaian_item.lot_number = item['lot_number'];
    _pemakaian_item.status = item['status'];
    _pemakaian_item.status_desc = item['status_desc'];
    _pemakaian_item.stock = item['stock'];
    _pemakaian_item_service.save_Pemakaian_Item(_pemakaian_item);
    print('Download Pemakaian Detail Item');
    print('pemakai_id:${_pemakaian_item.pemakai_id}');
    print('item_desc:${_pemakaian_item.item_desc}');
    print('item_number:${_pemakaian_item.item_number}');
    print('item_satuan:${_pemakaian_item.item_satuan}');
    print('lot_number:${_pemakaian_item.lot_number}');
    print('status:${_pemakaian_item.status}');
    print('status_desc:${_pemakaian_item.status_desc}');
    print('stock:${_pemakaian_item.stock}');
  }
  @override
  Widget build(BuildContext context) {
    jumlahsync();
    jumlahsyncstatussatu();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        drawer: NavDrawer(),
        body: Stack(
          children: <Widget>[
         Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/background/greenbackground2.jpg"),
                      fit: BoxFit.cover)),
              height: 200.0,
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 64,
                      margin: EdgeInsets.only(bottom: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                           child: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  AssetImage('assets/background/anggota.png'),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Selamat Datang,",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 150,
                                height: 30,
            child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0),
                                  child: Text('$nama',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      )),
                                ),
                              )
                            ],
                          ),
    
                          SizedBox(
                            width: 50,
                          ),
                          Container(
                            height: 300,
                            child: Padding(
                                padding: EdgeInsets.only(top: 5.0, right: 10),
                                child: (('$jmlh' == 'null' ||
                                            '$jmlh' == '0' ||
                                            '$jmlh' == ''))
                                    ? Tab(
                                        child: GestureDetector(
                                        child: Column(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                synctoserver();
                                                Alert(context);
                                              },
                                              icon: const Icon(Icons.sync),
                                              color: Colors.blue[500],
                                              iconSize: 30.0,
                                            ),
                                          ],
                                        ),
                                      ))
                                    : Tab(
                                        child: Badge(
                                            badgeColor: Colors.red,
                                            shape: BadgeShape.square,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            position: BadgePosition.topEnd(
                                                top: 5, end: 5),
                                            padding: EdgeInsets.all(3),
                                            badgeContent: Text(
                                              "!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            child: GestureDetector(
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      var listpemakaikedua =
                                                          await _pemakaianService
                                                              .readPemakaikedua();
                                                      setState(() {
                                                        jml.text =
                                                            listpemakaikedua[0]
                                                                    ['jml']
                                                                .toString();
                                                      });
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      prefs.setString(
                                                          "jmlh", jml.text);
                                                      setState(() {
                                                        jmlh = prefs
                                                            .getString("jmlh");
                                                      });
                                                      print("$jmlh");
                                                      synctoserver();
                                                      Alert(context);
                                                    },
                                                    icon: const Icon(Icons.sync),
                                                    color: Colors.blue[500],
                                                    iconSize: 30.0,
                                                  ),
                                                ],
                                              ),
                                            )))),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          primary: false,
                          crossAxisCount: 3,
                          children: <Widget>[
                            Card(
                              child: Tab(
                                child: Badge(
                                  badgeColor: Colors.blue[200],
                                  shape: BadgeShape.square,
                                  borderRadius: BorderRadius.circular(5),
                                  position:
                                      BadgePosition.topEnd(top: 5, end: -20),
                                  padding: EdgeInsets.all(2),
                                  badgeContent: Text(
                                    'Online',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: InkWell(
                                      onTap: () {
                                        getListPinjam();
                                        Route route = MaterialPageRoute(
                                            builder: (context) =>
                                                ListPinjamItem());
                                        Navigator.push(context, route);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Material(
                                            child: Container(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child: Image.asset(
                                                    'assets/background/pinjam.png',
                                                    height: 40,
                                                    width: 40),
                                              ),
                                            ),
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 30.0),
                                          ),
                                          Text(
                                            'Pinjam Item',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ),
    
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.red,
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -15),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Offline',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    Alertmenupemakaian(context);
                                    await new Future.delayed(
                                        const Duration(seconds: 2));
                                    Route route = MaterialPageRoute(
                                        builder: (context) => DataLocal());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/pemakai.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Pemakaian Item',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.blue[200],
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -15),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Online',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => Stok());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/request.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Request Item',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.blue[200],
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -20),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Online',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => ApprovalRequest());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/approve.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Approval Req',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.blue[200],
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -11),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Online',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => PelayananRequest());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/pelayanan.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Pelayanan Req',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.blue[200],
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -20),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Online',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => Pengiriman());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/pengiriman.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Pengiriman',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                badgeColor: Colors.blue[200],
                                shape: BadgeShape.square,
                                borderRadius: BorderRadius.circular(5),
                                position: BadgePosition.topEnd(top: 5, end: -20),
                                padding: EdgeInsets.all(2),
                                badgeContent: Text(
                                  'Online',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => Penerimaan());
                                    Navigator.push(context, route);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                          image: AssetImage(
                                              'assets/background/penerimaan.png'),
                                          height: 40,
                                          width: 40),
                                      new Padding(
                                        padding: new EdgeInsets.only(top: 30.0),
                                      ),
                                      Text('Penerimaan',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                                child: Tab(
                              child: Badge(
                                  badgeColor: Colors.blue[200],
                                  shape: BadgeShape.square,
                                  borderRadius: BorderRadius.circular(5),
                                  position:
                                      BadgePosition.topEnd(top: 5, end: -25),
                                  padding: EdgeInsets.all(2),
                                  badgeContent: Text(
                                    'Online',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Route route = MaterialPageRoute(
                                          builder: (context) => CekStok());
                                      Navigator.push(context, route);
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image(
                                            image: AssetImage(
                                                'assets/background/stok.png'),
                                            height: 40,
                                            width: 40),
                                        new Padding(
                                          padding: new EdgeInsets.only(top: 30.0),
                                        ),
                                        Text('Cek Stok',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  )),
                            )),
                          ]),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
