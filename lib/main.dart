import 'dart:convert';
import 'dart:io';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homeScreen2.dart';
import 'package:http/http.dart' as http;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var user = preferences.getString('user');
  runApp(MyApp());
}

String username;
String nama;
String userid;
String jmlapi;

final String base = 'http://alkes.inacare.org';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alkes Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/HomeScreen': (BuildContext context) => new HomeScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String base;
  MyHomePage({
    this.base,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController baseUrl = TextEditingController();
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  TextEditingController fullnama = new TextEditingController();
  var _pemakaian = Pemakaian();
  var _pemakaianService = Pemakaian_Item_Service();
  var jml = TextEditingController();

  String msg = '';
  @override
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<List> _login() async {
    
    final response = await http.post('$base/index.php?r=api/login', body: {
      "username": user.text,
      "password": pass.text,
    });
    var datauser = json.decode(response.body);
    if (datauser.length == 0 || datauser[0] == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('username', user.text);
      setState(() {
        msg = "Login Fail";
      });
    } else {
      if (datauser[0]['level'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/HomeScreen');
      } else if (datauser[0]['level'] == 'member') {
        Navigator.pushReplacementNamed(context, '/MemberPage');
      }
      print('Username:${datauser[0]['username']}');
      print('Nama:${datauser[0]['full_name']}');
      setState(() {
        username = datauser[0]['username'];
        nama = datauser[0]['full_name'].toString();
        userid = datauser[0]['userid'].toString();
      });
      return datauser;
    }
  }
  File file;
  String Jml;
  var _pemakaian_item_service = Pemakaian_Item_Service();
  var _pemakaian_item = Pemakaian_item();
 Future<String> uploadImage(filepath, url) async {
    final request = http.MultipartRequest('POST', (url));
    request.files.add(http.MultipartFile('Pemakai[bast]',
        File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
        filename: filepath.split("/").last));
    var res = await request.send();
  }
  Future synctoserver() async {
    var listpemakaikedua = await _pemakaianService.readPemakaikedua();
    setState(() {
      jml.text = listpemakaikedua[0]['jml'].toString();
    });
    print("$jml");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Jml", jml.text);
    setState(() {
      Jml = prefs.getString("Jml");
    });
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
    _pemakaianService.updatesync();

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
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/logos/phaprospattern.png"),
                      fit: BoxFit.cover)),
            ),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 60.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: 220,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage("assets/logos/PTPhaprosTbk.png"),
                              fit: BoxFit.cover)),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'OpenSans',
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _buildEmailTF(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildPasswordTF(),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      msg,
                      style: TextStyle(fontSize: 12.0, color: Colors.red),
                    ),
                    _buildLoginBtn(),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'User Name',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: user,
          decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.green,
            ),
            hintText: 'Username',
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.green),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.teal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            )
            ),
        SizedBox(height: 2.0),
        TextField(
          controller: pass,
          obscureText: _obscureText,
          decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.green,
            ),
            suffix: InkWell(
              onTap: _toggle,
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.green,
              ),
            ),
            hintText: 'Password',
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.green),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.teal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: TextButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.green,
            elevation: 5,
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
        onPressed: () {
          synctoserver();
          _login();
        },
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
}
