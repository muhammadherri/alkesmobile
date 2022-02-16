import 'dart:convert';
import 'dart:io';
import 'package:alkes/menu/PemakaianItem/detailTopup.dart';
import 'package:alkes/menu/PemakaianItem/detaildatalocal.dart';
import 'package:alkes/sqlite6/models/pemakaian.dart';
import 'package:alkes/sqlite6/models/pemakaian_item.dart';
import 'package:alkes/sqlite6/services/pemakaian_itemService.dart';
import 'package:dio/dio.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../homeScreen2.dart';
import 'package:alkes/main.dart';
@immutable
class DataLocal extends StatefulWidget {
  String inventory;

  DataLocal({this.inventory});
  @override
  _DataLocalState createState() => _DataLocalState(
      inventory: ['inventory'].toString());
}

class _DataLocalState extends State<DataLocal> {
  var Pinjam;

  String pemakaianid = _edit_pemakai_idCont.text;
  String itemnumbr = _edit_item_numberCont.text;
  String date = _edit_pemakai_dateCont.text;
  String status = _edit_statusCont.text;
  String itemdesc = _edit_item_descCont.text;
  String itemsatuan = _edit_item_satuanCont.text;
  String stock = _edit_stockCont.text;
  String statusdesc = _edit_status_descCont.text;
  var jml = TextEditingController();
  String jmlh;
  String Jml;
  int pemID;
  var Pemakai;
  String PemakaiID = '';
  void setIntoPemakaiID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", _editpemakai_id.text);
  }

  List list;
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  Future<bool> saveVideo(String url, String uploadBast) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/RPSApp";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$uploadBast");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile(File imageFile) async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
        "video.mp4");
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

  File image;
  String itmnmber;
  String itmndes;
  String itmstok;
  String itmstuan;
  String itmltnumbr;
  String stts;
  var model = "";
  String mode = "";
  String isset = "";
  static File _image;
  String inventory;
  var context;
  var pemakai_id;
  var _teknisi = TextEditingController();
  var _editforpemakai_id = TextEditingController();
  var _editpemakai_id = TextEditingController();
  var _editpemakai_no = TextEditingController();
  var _editpemakai_date = TextEditingController();
  var _editpemakai_cabang = TextEditingController();
  var _editpemakai_rs = TextEditingController();
  var _editpinjam_by = TextEditingController();
  var _editpemakai_dokter = TextEditingController();
  var _editpinjam_date = TextEditingController();
  var _editpemakai_by = TextEditingController();
  var _editpemakai_paket = TextEditingController();
  var _editcreated_at = TextEditingController();
  var _editupdated_at = TextEditingController();
  var _editpemakai_bast = TextEditingController();
  var _editpaket_name = TextEditingController();
  var _editteknisi = TextEditingController();

  var pemakaian;
  var _pemakaian = Pemakaian();
  var _pemakaianService = Pemakaian_Item_Service();
  List<Pemakaian> _pemakaiList = <Pemakaian>[];
  TextEditingController namabarang = TextEditingController(text: "");
  var _edit_lot_numberCont = TextEditingController();
  var pemakaian_item;
  var _pemakaian_item = Pemakaian_item();
  var _pemakaian_item_service = Pemakaian_Item_Service();
  List<Pemakaian_item> _pemakaian_item_List = <Pemakaian_item>[];
  _DataLocalState(
      {this.pemakai_id,
      this.inventory,
      this.list});

  @override
  void initState() {
    super.initState();
    mode = ('mode');
    getAllPemakai();
  }

  _buildPopup(BuildContext context) {
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
                      "Pemakaian",
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
            Center(
              child: _image == null
                  ? Text('Belum Mengambil Gambar',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red))
                  : Text("Yeay,Berhasil Memakai Item",
                      style: TextStyle(
                          color: Colors.lightGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
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
                        image: _image == null
                            ? AssetImage("assets/background/cancel.png")
                            : AssetImage("assets/background/checkmark.png"),
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
              "Memakai Item Yang di Minta",
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
                        MaterialPageRoute(builder: (context) => DataLocal()),
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }
  Future PemakaiHeader() async {
    _pemakaian.id = pemakaian[0]['id'];
    _pemakaian.pemakai_by = "$userid";
    _pemakaian.pemakai_status = 2;
    _pemakaian.pemakai_bast = "$callimage";
    _pemakaian.status_description = 'Pakai';
    _pemakaian.teknisi = _teknisi.text;

    _pemakaian.pemakai_no = pemakaian[0]['pemakai_no'];
    _pemakaian.pemakai_id = pemakaian[0]['pemakai_id'];
    _pemakaian.pemakai_date = pemakaian[0]['pemakai_date'];
    _pemakaian.pemakai_cabang = pemakaian[0]['pemakai_cabang'];
    _pemakaian.pemakai_rs = pemakaian[0]['pemakai_rs'];

    _pemakaian.pinjam_by = pemakaian[0]['pinjam_by'];
    _pemakaian.pemakai_dokter = pemakaian[0]['pemakai_dokter'];
    _pemakaian.pinjam_date = pemakaian[0]['pinjam_date'];
    _pemakaian.pemakai_paket = pemakaian[0]['pemakai_paket'];
    _pemakaian.created_at = pemakaian[0]['created_at'];
    _pemakaian.updated_at = pemakaian[0]['updated_at'];
    _pemakaianService.updatePemakaian(_pemakaian);

    print('pemakai_no:${_pemakaian.pemakai_no}');
    print('pemakai_id:${_pemakaian.pemakai_id}');
    print('pemakai_date:${_pemakaian.pemakai_date}');
    print('pemakai_cabang:${_pemakaian.pemakai_cabang}');
    print('pemakai_rs:${_pemakaian.pemakai_rs}');

    print('pinjam_by:${'$userid'}');
    print('pemakai_dokter:${_pemakaian.pemakai_dokter}');
    print('pinjam_date:${_pemakaian.pinjam_date}');
    print('pemakai_paket:${_pemakaian.pemakai_paket}');
    print('created_at:${_pemakaian.created_at}');
    print('updated_at:${_pemakaian.updated_at}');

    print('pemakai_by:${_pemakaian.pemakai_by}');
    print('pemakai_status:${_pemakaian.pemakai_status}');
    print('pemakai_bast:${_pemakaian.pemakai_bast}');
    print('status_description:${_pemakaian.status_description}');
    print('teknisi:${_pemakaian.teknisi}');
  }
  String code = "";
  String getcode = '';
  String getwocode;
  String message;
  int sts = 1;
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
            '/storage/emulated/0/Android/data/com.example.alkes/files/Pictures/$namafile';
        final url = Uri.parse(
            "$base/index.php?r=api/update&model=pemakai&id=$PemakaiId");
        var request = http.MultipartRequest('POST', url);
        request.fields["Pemakai[pemakai_status]"] = '$status';
        request.fields["Pemakai[teknisi]"] = pakai["teknisi"];

        print('hasilfile : $bastfile');
        print('Upload Pemakai');
        print('sttus pemakai $PemakaiId ');
        print('namafile $namafile ');
        print('status$status');
        var pic = http.MultipartFile.fromPath("bast", '$bastfile');
        var response = request.send();
      }
    });
    _pemakaianService.deletePemakai_status();
    _pemakaian_item_service.Delete_Pemakaian_Item();
    await new Future.delayed(const Duration(seconds: 5));
    final response = await http.get(
        "$base/index.php?r=api/list&model=pemakai&mode=1&userid=$userid&pemakai_status=1");
    var listPeminjam = json.decode(response.body);
    listPeminjam.forEach((pinjam) {
      syncPemakai(pinjam);
    });
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

  scanbarcode(BuildContext context) async {
    getcode = await FlutterBarcodeScanner.scanBarcode(
        "#009922", "Keluar", true, ScanMode.DEFAULT);
    print('Print GetCode :$getcode');
    getwocode = getcode.length > 29 ? getcode.substring(29) : "1";

    print('Print GetCode ke 2 :$getwocode');
    setState(() {
      _edit_lot_numberCont.text = getwocode;
      message = 'Lot Tidak Ditemukan';
    });
    var itemList = _pemakaian_item_List;
    itemList.forEach((detailitem) {
      detailitem.id;
      detailitem.pemakai_id;
      detailitem.item_number;
      detailitem.lot_number;
      detailitem.pemakai_date;
      if (detailitem.status == 1 &&
          detailitem.lot_number == _edit_lot_numberCont.text) {
        _pemakaian_item.id = detailitem.id;
        _pemakaian_item.pemakai_id = detailitem.pemakai_id;
        _pemakaian_item.item_number = detailitem.item_number;
        _pemakaian_item.pemakai_date = detailitem.pemakai_date;
        _pemakaian_item.lot_number = detailitem.lot_number;
        _pemakaian_item.status = 2;
        _pemakaian_item.item_desc = detailitem.item_desc;
        _pemakaian_item.item_satuan = detailitem.item_satuan;
        _pemakaian_item.stock = detailitem.stock;
        _pemakaian_item.status_desc = 'Pakai';
        message = 'success';
        var lot_number = detailitem.lot_number;
        print('$pemakai_id,$lot_number');
        var result =
            _pemakaian_item_service.update_Pemakaian_Item(_pemakaian_item);
        var updateterpakai = _pemakaian_item_service
            .updateterpakai_Pemakaian_Item(pemakai_id, lot_number);

        print(updateterpakai);
      }
      detailitem.status;
      detailitem.item_desc;
      detailitem.item_satuan;
      detailitem.stock;
      detailitem.status_desc;
    });
    _message(context);
    getAllPemakaianItem();
  }

  var syspaths;
  var path;

  void saveimage() async {
    final response =
        await http.post("$base/index.php?r=api/create&model=pemakai", body: {
    });
    return json.decode(response.body);
  }

  String callimage;
  Future<void> getCameraImageGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile == null) {
      return;
    }
    print('Original path: $imageFile');
    final tempDir = await getTemporaryDirectory();
    var path = tempDir.path;
    String fileName =
        imageFile == null ? 'Kosong' : imageFile.path.split('/').last;
    print('filename: $fileName');
    setState(() {
      _image = imageFile;
      callimage = fileName;
    });
    print('file:$_image');
  }

  Future upload(File imageFile) async {
    print("print image:$_image");
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var uri;
  }

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pemakai_id", _editpemakai_id.text);
  }
  getAllPemakai() async {
    _pemakaiList = <Pemakaian>[];
    var pemakaian = await _pemakaianService.readPemakai();
    pemakaian.forEach((pemakaian) {
      setState(() {
        var pemakaianModel = Pemakaian();
        pemakaianModel.id = pemakaian['id'];
        pemakaianModel.pemakai_id = pemakaian['pemakai_id'];
        pemakaianModel.pemakai_no = pemakaian['pemakai_no'];
        pemakaianModel.pemakai_date = pemakaian['pemakai_date'];
        pemakaianModel.pemakai_cabang = pemakaian['pemakai_cabang'];
        pemakaianModel.pemakai_rs = pemakaian['pemakai_rs'];
        pemakaianModel.pemakai_by = pemakaian['pemakai_by'];
        pemakaianModel.pemakai_dokter = pemakaian['pemakai_dokter'];
        pemakaianModel.pinjam_date = pemakaian['pinjam_date'];
        pemakaianModel.pinjam_by = pemakaian['pinjam_by'];
        pemakaianModel.pemakai_status = pemakaian['pemakai_status'];
        pemakaianModel.pemakai_paket = pemakaian['pemakai_paket'];
        pemakaianModel.created_at = pemakaian['created_at'];
        pemakaianModel.updated_at = pemakaian['updated_at'];
        pemakaianModel.pemakai_bast = pemakaian['pemakai_bast'];
        pemakaianModel.paket_name = pemakaian['paket_name'];
        pemakaianModel.teknisi = pemakaian['teknisi'];
        _pemakaiList.add(pemakaianModel);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.green,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.green),
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
          "Pemakaian Barang",
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
        child: ListView.builder(
          itemCount: _pemakaiList.length,
          itemBuilder: (context, index) {
            return Card(
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
                          'Pemakaian Item',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 63.0),
                      ),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: _pemakaiList[index].pemakai_status == 1
                              ? Colors.blue
                              : _pemakaiList[index].pemakai_status == 2
                                  ? Colors.green
                                  : Colors.red,
                          minimumSize: Size(88, 1),
                          padding: EdgeInsets.all(1.0),
                        ),
                        onPressed: () {},
                        child: Text(
                            _pemakaiList[index].pemakai_status == 1
                                ? 'Pinjam'
                                : _pemakaiList[index].pemakai_status == 2
                                    ? 'Pakai'
                                    : 'Selesai',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
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
                              width: 140,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(_pemakaiList[index].pemakai_no,
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            Container(
                              width: 0,
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            Container(
                              width: 70,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(_pemakaiList[index].pemakai_dokter,
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 140,
                              height: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Text(_pemakaiList[index].pemakai_rs,
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
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
                                    print('print jmhl:$jmlh');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailLocal(
                                                Pinjam: _pemakaiList[index],
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
            ));
          },
        ),
      ),
    );
  }

  TextEditingController pemakai_no = TextEditingController();
  TextEditingController pemakai_date = TextEditingController();
  TextEditingController pemakai_cabang = TextEditingController();
  TextEditingController pemakai_rs = TextEditingController();
  TextEditingController pinjam_by = TextEditingController();
  TextEditingController pemakai_dokter = TextEditingController();
  TextEditingController pinjam_date = TextEditingController();
  TextEditingController pemakai_by = TextEditingController();
  detailHeader(BuildContext context, pemakai_ID) async {
    await new Future.delayed(const Duration(seconds: 1));
    pemakaian = await _pemakaianService.readPemakayById(pemakai_ID);
    setState(() {
      pemakai_id.text = pemakaian[0]['pemakai_id'];
      pemakai_no.text = pemakaian[0]['pemakai_no'] ?? 'Pemakai No';
      pemakai_date.text = pemakaian[0]['pemakai_date'] ?? 'Pemakai Date';
      pemakai_cabang.text = pemakaian[0]['pemakai_cabang'] ?? 'Pemakai Cabang';
      pemakai_rs.text = pemakaian[0]['pemakai_rs'] ?? 'Rumah Sakit';
      pinjam_by.text = pemakaian[0]['pinjam_by'] ?? 'Pinjam By';
      pemakai_dokter.text = pemakaian[0]['pemakai_dokter'] ?? 'Pemakai Dokter';
      pinjam_date.text = pemakaian[0]['pinjam_date'] ?? 'Pinjam Date';
      pemakai_by.text = pemakaian[0]['pemakai_by'] ?? 'Pemakai By';
    });
    Detail(context);
  }

  void setalert() async {
    var listpemakaikedua = await _pemakaianService.readPemakaikedua();
    setState(() {
      jml.text = listpemakaikedua[0]['jml'].toString();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("jmlh", jml.text);
  }

  _editPemakai(BuildContext context, pemakai_ID) async {
    await new Future.delayed(const Duration(seconds: 1));
    pemakaian = await _pemakaianService.readPemakayById(pemakai_ID);
    setState(() {
      _editpemakai_id.text = pemakaian[0]['pemakai_id'].toString() ?? 'No ID';
      _editpemakai_no.text = pemakaian[0]['pemakai_no'] ?? 'Pemakai No';
      _editpemakai_date.text = pemakaian[0]['pemakai_date'] ?? 'Pemakai Date';
      _editpemakai_cabang.text =
          pemakaian[0]['pemakai_cabang'] ?? 'Pemakai Cabang';
      _editpemakai_rs.text = pemakaian[0]['pemakai_rs'] ?? 'Rumah Sakit';
      _editpinjam_by.text = pemakaian[0]['pinjam_by'] ?? 'Pinjam By';
      _editpemakai_dokter.text =
          pemakaian[0]['pemakai_dokter'] ?? 'Pemakai Dokter';
      _editpinjam_date.text = pemakaian[0]['pinjam_date'] ?? 'Pinjam Date';
      _editpemakai_by.text = pemakaian[0]['pemakai_by'] ?? 'Pemakai By';
      _editpemakai_paket.text =
          pemakaian[0]['pemakai_paket'] ?? 'Pemakai Paket';
      _editcreated_at.text = pemakaian[0]['created_at'] ?? 'Created At';
      _editupdated_at.text = pemakaian[0]['updated_at'] ?? 'Update At';
      _editpemakai_bast.text = pemakaian[0]['pemakai_bast'] ?? 'Pemakai Bast';
      _editpaket_name.text = pemakaian[0]['paket_name'] ?? 'Paket Name';
      _editteknisi.text = pemakaian[0]['teknisi'] ?? 'Paket Name';
    });
    Detail(context);
  }

  _editPemakaianItem(BuildContext context, pemakaiID) async {
    await new Future.delayed(const Duration(seconds: 10));
    pemakaian_item =
        await _pemakaianService.read_Pemakaian_ItemByPemakaiID(pemakaiID);
    setState(() {
      _edit_pemakai_idCont.text = pemakaian_item[0]['pemakai_id'].toString();
      _edit_item_numberCont.text = pemakaian_item[0]['item_number'];
      _edit_pemakai_dateCont.text = pemakaian_item[0]['pemakai_date'];
      _edit_lot_numberCont.text = pemakaian_item[0]['lot_number'];
      _edit_statusCont.text = pemakaian_item[0]['status'].toString();
      _edit_item_descCont.text = pemakaian_item[0]['item_desc'];
      _edit_item_satuanCont.text = pemakaian_item[0]['item_satuan'];
      _edit_stockCont.text = pemakaian_item[0]['stock'];
      _edit_status_descCont.text = pemakaian_item[0]['status_desc'];
      String pemakaianid = _edit_pemakai_idCont.text;
      String itemnumbr = _edit_item_numberCont.text;
      String date = _edit_pemakai_dateCont.text;
      String lotnumbr = _edit_lot_numberCont.text;
      String status = _edit_statusCont.text;
      String itemdesc = _edit_item_descCont.text;
      String itemsatuan = _edit_item_satuanCont.text;
      String stock = _edit_stockCont.text;
      String statusdesc = _edit_status_descCont.text;
      print(
          'pemakai_id:$pemakaianid,item number:$itemnumbr,pemakai date:$date,lot number:$lotnumbr,status:$status,item desc:$itemdesc,item satuan:$itemsatuan,stock:$stock,$statusdesc');
    });
  }

  getAllPemakaianItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PemakaiID", _editpemakai_id.text);

    var pemakaian = await _pemakaianService.readPemakai();
    setState(() {
      _editforpemakai_id.text =
          pemakaian[0]['pemakai_id'].toString() ?? 'No ID';
      PemakaiID = prefs.getString("PemakaiID");
    });
    var pemakaiId = _editforpemakai_id.text;
    print('PEMAKAI ID:$pemakaiId');
    var pemakaianitems =
        await _pemakaian_item_service.read_Pemakaian_ItemByPemakaiID(PemakaiID);
    pemakaianitems.forEach((pemakaian_item) {
      setState(() {
        var pemakaian_itemModel = Pemakaian_item();
        pemakaian_itemModel.id = pemakaian_item['id'];
        pemakaian_itemModel.pemakai_id = pemakaian_item['pemakai_id'];
        pemakaian_itemModel.item_number = pemakaian_item['item_number'];
        pemakaian_itemModel.pemakai_date = pemakaian_item['pemakai_date'];
        pemakaian_itemModel.lot_number = pemakaian_item['lot_number'];
        pemakaian_itemModel.status = pemakaian_item['status'];
        pemakaian_itemModel.item_desc = pemakaian_item['item_desc'];
        pemakaian_itemModel.item_satuan = pemakaian_item['item_satuan'];
        pemakaian_itemModel.stock = pemakaian_item['stock'];
        pemakaian_itemModel.status_desc = pemakaian_item['status_desc'];
        _pemakaian_item_List.add(pemakaian_itemModel);
        print('id:${pemakaian_itemModel.id}');
        print('pemakai_id:${pemakaian_itemModel.pemakai_id}');
        print('item_number:${pemakaian_itemModel.item_number}');
        print('pemakai_date:${pemakaian_itemModel.pemakai_date}');
        print('lot_number:${pemakaian_itemModel.lot_number}');
        print('status:${pemakaian_itemModel.status}');
        print('item_desc:${pemakaian_itemModel.item_desc}');
        print('item_satuan:${pemakaian_itemModel.item_satuan}');
        print('stock:${pemakaian_itemModel.stock}');
        print('status_desc:${pemakaian_itemModel.status_desc}');
      });
    });
  }

  Detail(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
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
                      MaterialPageRoute(builder: (context) => DataLocal()),
                    );
                  },
                ),
                centerTitle: true,
                backgroundColor: Color(0xFFc7f2e9),
                title: Text(
                  "Detail Pemakaian Barang",
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Text(
                                  'Detail Pemakaian',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 0,
                                                        height: 00,
                                                        child: Text("ID",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 0,
                                                        height: 0,
                                                        child: Text(
                                                            pemakai_id =
                                                                _editpemakai_id
                                                                    .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 14,
                                                        child: Text(
                                                            "Tanggal Pinjam",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        height: 12,
                                                        child: Text(
                                                            // pinjam_date =
                                                            _editpinjam_date
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 15,
                                                        child: Text('',
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        height: 15,
                                                        child: Text('',
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text("Pemohon",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            // pemakai_cabang =
                                                            _editpemakai_cabang
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Nomor Pinjam",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            // pemakai_no =
                                                            _editpemakai_no
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Rumah Sakit",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_rs
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Nama Dokter",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_dokter
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Paket Operasi",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpaket_name
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      TextButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0))),
                                                          primary:
                                                              Color(0xFFc7f2e9),
                                                          minimumSize:
                                                              Size(300, 1),
                                                          elevation: 5,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  11.0),
                                                        ),
                                                        onPressed: () {
                                                          scanbarcode(context);
                                                        },

                                                        label: Text(
                                                          'Scan Untuk Checking',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                        icon: Icon(
                                                          Icons
                                                              .all_out_outlined,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 400,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: _teknisi,
                              decoration: InputDecoration(
                                  labelText: "Teknisi",
                                  hintText: "Teknisi",
                                  border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0)))),
                        ),
                      ],
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
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Container(
                                                width: 250,
                                                height: 20,
                                                child: Text(
                                                    "Daftar Pemakaian Item",
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                onPressed: () {
                                                  print(
                                                      'pEmAkAiAn:$pemakai_id');
                                                  getCameraImageGallery();
                                                  alert(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  primary: Color(0xFFc7f2e9),
                                                  minimumSize: Size(300, 1),
                                                  elevation: 5,
                                                  padding: EdgeInsets.all(11.0),
                                                ),

                                                label: Text(
                                                  'Upload BAST',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                                icon: Icon(
                                                  Icons.photo,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  primary: Color(0xFFc7f2e9),
                                                  minimumSize: Size(300, 1),
                                                  elevation: 5,
                                                  padding: EdgeInsets.all(11.0),
                                                ),
                                                onPressed: () async {
                                                  setIntoSharedPreferences();
                                                  print("id:$pemakai_id");
                                                  final response = await http.get(
                                                      "$base/index.php?r=api/view&model=pemakai&id=$pemakai_id");
                                                  var jsonpemakai = json
                                                      .decode(response.body);
                                                  setState(() {
                                                    Pemakai =
                                                        jsonpemakai["data"];
                                                    print(
                                                        'counter value : $Pemakai');
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Topup(
                                                              Pinjam: Pemakai,
                                                            )),
                                                  );
                                                },

                                                label: Text(
                                                  'Top Up',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                                icon: Icon(
                                                  Icons.money_outlined,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: new Card(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                          width: 250,
                                                          height: 20,
                                                          child: Text(
                                                              "Item Detail",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 165,
                                                          height: 30,
                                                          child: Text("Item",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 30,
                                                          child: Text("Stock",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 30,
                                                          child: Text("No Lot",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 350,
                                                          height: 153,
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      _pemakaian_item_List
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return new Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5.0),
                                                                      child:
                                                                          new GestureDetector(
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          scrollDirection:
                                                                              Axis.horizontal,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 140,
                                                                                    height: 70,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Align(
                                                                                          alignment: Alignment.centerLeft,
                                                                                          child: Text(_pemakaian_item_List[index].item_number, style: TextStyle(fontSize: 12)),
                                                                                        ),
                                                                                        Align(
                                                                                          alignment: Alignment.centerLeft,
                                                                                          child: Text(_pemakaian_item_List[index].item_desc, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 20,
                                                                                    height: 70,
                                                                                  ),
                                                                                  Container(
                                                                                    width: 20,
                                                                                    height: 70,
                                                                                    child: Text(_pemakaian_item_List[index].stock.toString(), style: TextStyle(fontSize: 12)),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 25,
                                                                                    height: 70,
                                                                                    child: Text(_pemakaian_item_List[index].item_satuan, style: TextStyle(fontSize: 12)),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 30,
                                                                                    height: 70,
                                                                                  ),
                                                                                  Container(
                                                                                    width: 100,
                                                                                    height: 70,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Align(alignment: Alignment.center, child: Text(_pemakaian_item_List[index].lot_number == null ? "Not Set" : _pemakaian_item_List[index].lot_number, style: TextStyle(fontSize: 12, color: _pemakaian_item_List[index].lot_number == null ? Colors.red : Colors.black))),
                                                                                        Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: TextButton(
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                  minimumSize: Size(70, 1),
                                                                                                  padding: EdgeInsets.all(1.0),
                                                                                                  primary: _pemakaian_item_List[index].status == 1
                                                                                                      ? Colors.blue
                                                                                                      : _pemakaian_item_List[index].status == 2
                                                                                                          ? Colors.green
                                                                                                          : Colors.red),
                                                                                              child: Container(
                                                                                                child: Text(
                                                                                                  _pemakaian_item_List[index].status == 1
                                                                                                      ? 'Pinjam'
                                                                                                      : _pemakaian_item_List[index].status == 2
                                                                                                          ? 'Pakai'
                                                                                                          : 'Terpakai',
                                                                                                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                              onPressed: () {}),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
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
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 4.0,
                backgroundColor: Color(0xFFc7f2e9),
                label: const Text(
                  'Pakai',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  PemakaiHeader();
                  print('Pemakaian_id:$pemakai_id');
                  print('userid:$userid');
                  _buildPopup(context);
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
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
        });
  }
  Detail2(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
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
                      MaterialPageRoute(builder: (context) => DataLocal()),
                    );
                  },
                ),
                centerTitle: true,
                backgroundColor: Color(0xFFc7f2e9),
                title: Text(
                  "Detail Pemakaian Barang",
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Text(
                                  'Detail Pemakaian',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 0,
                                                        height: 00,
                                                        child: Text("ID",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 0,
                                                        height: 0,
                                                        child: Text(
                                                            pemakai_id =
                                                                _editpemakai_id
                                                                    .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 14,
                                                        child: Text(
                                                            "Tanggal Pinjam",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        height: 12,
                                                        child: Text(
                                                            // pinjam_date =
                                                            _editpinjam_date
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 15,
                                                        child: Text('',
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        height: 15,
                                                        child: Text('',
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text("Pemohon",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_cabang
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Nomor Pinjam",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_no
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Rumah Sakit",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_rs
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Nama Dokter",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpemakai_dokter
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            "Paket Operasi",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      Container(
                                                        width: 140,
                                                        height: 30,
                                                        child: Text(
                                                            _editpaket_name
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      TextButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0))),
                                                          primary:
                                                              Color(0xFFc7f2e9),
                                                          minimumSize:
                                                              Size(300, 1),
                                                          elevation: 5,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  11.0),
                                                        ),
                                                        onPressed: () {
                                                          scanbarcode(context);
                                                        },

                                                        label: Text(
                                                          'Scan Untuk Checking',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                        icon: Icon(
                                                          Icons
                                                              .all_out_outlined,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 400,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: _teknisi,
                              decoration: InputDecoration(
                                  labelText: "Teknisi",
                                  hintText: "Teknisi",
                                  border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0)))),
                        ),
                      ],
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
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Container(
                                                width: 250,
                                                height: 20,
                                                child: Text(
                                                    "Daftar Pemakaian Item",
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                onPressed: () {
                                                  print(
                                                      'pEmAkAiAn:$pemakai_id');
                                                  getCameraImageGallery();
                                                  alert(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  primary: Color(0xFFc7f2e9),
                                                  minimumSize: Size(300, 1),
                                                  elevation: 5,
                                                  padding: EdgeInsets.all(11.0),
                                                ),

                                                label: Text(
                                                  'Upload BAST',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                                icon: Icon(
                                                  Icons.photo,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  primary: Color(0xFFc7f2e9),
                                                  minimumSize: Size(300, 1),
                                                  elevation: 5,
                                                  padding: EdgeInsets.all(11.0),
                                                ),
                                                onPressed: () async {
                                                  setIntoSharedPreferences();
                                                  print("id:$pemakai_id");
                                                  final response = await http.get(
                                                      "$base/index.php?r=api/view&model=pemakai&id=$pemakai_id");
                                                  var jsonpemakai = json
                                                      .decode(response.body);
                                                  setState(() {
                                                    Pemakai =
                                                        jsonpemakai["data"];
                                                    print(
                                                        'counter value : $Pemakai');
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Topup(
                                                              Pinjam: Pemakai,
                                                            )),
                                                  );
                                                },

                                                label: Text(
                                                  'Top Up',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                                icon: Icon(
                                                  Icons.money_outlined,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding:
                                                new EdgeInsets.only(top: 10.0),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: new Card(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                          width: 250,
                                                          height: 20,
                                                          child: Text(
                                                              "Item Detail",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 165,
                                                          height: 30,
                                                          child: Text("Item",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 30,
                                                          child: Text("Stock",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 30,
                                                          child: Text("No Lot",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 350,
                                                          height: 153,
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      _pemakaian_item_List
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return new Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5.0),
                                                                      child:
                                                                          new GestureDetector(
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          scrollDirection:
                                                                              Axis.horizontal,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 140,
                                                                                    height: 70,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Align(
                                                                                          alignment: Alignment.centerLeft,
                                                                                          child: Text(itmnmber = _pemakaian_item_List[index].item_number, style: TextStyle(fontSize: 12)),
                                                                                        ),
                                                                                        Align(
                                                                                          alignment: Alignment.centerLeft,
                                                                                          child: Text(itmndes = _pemakaian_item_List[index].item_desc, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 20,
                                                                                    height: 70,
                                                                                  ),
                                                                                  Container(
                                                                                    width: 20,
                                                                                    height: 70,
                                                                                    child: Text(itmstok = _pemakaian_item_List[index].stock.toString(), style: TextStyle(fontSize: 12)),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 25,
                                                                                    height: 70,
                                                                                    child: Text(itmstuan = _pemakaian_item_List[index].item_satuan, style: TextStyle(fontSize: 12)),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 30,
                                                                                    height: 70,
                                                                                  ),
                                                                                  Container(
                                                                                    width: 100,
                                                                                    height: 70,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Align(alignment: Alignment.center, child: Text(_pemakaian_item_List[index].lot_number == null ? "Not Set" : _pemakaian_item_List[index].lot_number, style: TextStyle(fontSize: 12, color: _pemakaian_item_List[index].lot_number == null ? Colors.red : Colors.black))),
                                                                                        Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: TextButton(
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                  minimumSize: Size(70, 1),
                                                                                                  padding: EdgeInsets.all(1.0),
                                                                                                  primary: (_edit_statusCont.text == '1')
                                                                                                      ? Colors.blue
                                                                                                      : (_edit_statusCont.text == '2')
                                                                                                          ? Colors.green
                                                                                                          : Colors.red),
                                                                                              child: Container(
                                                                                                child: Text(
                                                                                                  (_edit_statusCont.text == '1')
                                                                                                      ? 'Pinjam'
                                                                                                      : (_edit_statusCont.text == '2')
                                                                                                          ? 'Pakai'
                                                                                                          : 'Terpakai',
                                                                                                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                              onPressed: () {}),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
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
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 4.0,
                backgroundColor: Color(0xFFc7f2e9),
                label: const Text(
                  'Pakai',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  PemakaiHeader();
                  print('Item Detail');
                  print('Item Number:$itmnmber');
                  print('Item Desc:$itmndes');
                  print('Item Stock:$itmstok');
                  print('Item Satuan:$itmstuan');
                  print('Lot Number:$itmltnumbr');
                  print('Status:$stts');
                  _buildPopup(context);
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
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
        });
  }
  _message(context) {
    print('hasil result:$message');
    return showDialog(
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
                      "Scan Barcode",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Hasil Scanning", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                textAlign: (TextAlign.center),
                style: TextStyle(
                    color: "${message}" == 'success'
                        ? Colors.lightGreen
                        : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
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
                        image: "${message}" == 'success'
                            ? AssetImage("assets/background/checkmark.png")
                            : AssetImage("assets/background/cancel.png"),
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),

            new Padding(
              padding: new EdgeInsets.only(top: 40.0),
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
      },
    );
  }

  alert(callimage) {
    print('hasil result:$callimage');
    return showDialog(
      barrierDismissible: false,
      context: callimage,
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
                      "Upload BAST",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(child: Text("Upload BAST", style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Container(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: "${callimage}" == 'Kosong'
                            ? AssetImage("assets/background/cancel.png")
                            : AssetImage("assets/background/checkmark.png"),
                      ),
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
      },
    );
  }
}
var _edit_pemakai_idCont = TextEditingController();
var _edit_item_numberCont = TextEditingController();
var _edit_pemakai_dateCont = TextEditingController();
var _edit_statusCont = TextEditingController();
var _edit_item_descCont = TextEditingController();
var _edit_item_satuanCont = TextEditingController();
var _edit_stockCont = TextEditingController();
var _edit_status_descCont = TextEditingController();
