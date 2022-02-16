import 'package:alkes/menu/Approval/approvalRequest.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alkes/main.dart';

class RejectRequest extends StatefulWidget {
  @override
  _RejectRequestState createState() => _RejectRequestState();
}

class _RejectRequestState extends State<RejectRequest> {
  String RequestID = "";
  TextEditingController catatan = TextEditingController();

  void SendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      RequestID = prefs.getString("RequestID");
    });
    final response = await http.post(
        "$base/index.php?r=api/update&model=request&id=$RequestID",
        body: {
          "Request[catatan_approval]": catatan.text,
          "Request[request_status]": "3",
          "Request[approve_by]": "$userid",
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            centerTitle: true,
            title: new Text(
              'Form Reject',
              style: TextStyle(
                color: Colors.white,
              ),
            )),
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
                          controller: catatan,
                          decoration: InputDecoration(
                              labelText: 'Alasan Reject',
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)))),
                    ],
                  )
                ],
              )),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          backgroundColor: Colors.red,
          label: const Text(
            'Reject',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            SendData();

            _buildPopupRejectDialog(context);
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

  void _buildPopupRejectDialog(BuildContext context) {
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
                      "Reject Request",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Center(
                child: Text("Data Berhasil di Reject ",
                    style: TextStyle(fontSize: 12))),
            new Padding(
              padding: new EdgeInsets.only(top: 5.0),
            ),
            Center(
                child: Text(
              "Berhasil Di Reject",
              style: TextStyle(
                  color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
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
              "Data sudah di Reject",
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
                          MaterialPageRoute(
                              builder: (context) => ApprovalRequest()),
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
