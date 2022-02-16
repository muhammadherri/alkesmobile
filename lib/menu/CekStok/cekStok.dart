import 'package:alkes/menu/CekStok/DaftarStokOnHand/menuStokOnHand.dart';
import 'package:alkes/menu/CekStok/searchStokNasional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../homeScreen2.dart';

class CekStok extends StatefulWidget {
  CekStok({this.username});

  final String username;
  @override
  _CekStokState createState() => _CekStokState();
}

class _CekStokState extends State<CekStok> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/background/greenbackground2.jpg"),
                      fit: BoxFit.cover)),
              height: 200.0,
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 64,
                      margin: EdgeInsets.only(bottom: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back_sharp,
                                              color: Colors.green),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()),
                                            );
                                          },
                                        ),
                                    Text("Menu Stock",style: TextStyle(fontSize: 20,color: Colors.green),)

                                      ],
                                    ),
                                  ],
                                ),
                              ])
                        ],
                      ),
                    ),
                    Container(
                      child: Expanded(
                        child: GridView.count(
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            primary: false,
                            crossAxisCount: 2,
                            children: <Widget>[
                              Card(
                                child: InkWell(
                                    onTap: () {
                                      Route route = MaterialPageRoute(
                                          builder: (context) => SearchStokNasional());
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
                                                  'assets/background/stoknasional.png',
                                                  height: 80,
                                                  width: 80),
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(top: 30.0),
                                        ),
                                        Text('Stok Nasional')
                                      ],
                                    )),
                              ),
                              Card(
                                  child: InkWell(
                                onTap: () {
                                  Route route = MaterialPageRoute(
                                      builder: (context) => menuStokOnHand());
                                  Navigator.push(context, route);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                        image: AssetImage(
                                            'assets/background/stokonhand.png'),
                                        height: 80,
                                        width: 80),
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 30.0),
                                    ),
                                    Text('Stok On Hand')
                                  ],
                                ),
                              )),
                            ]),
                      ),
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
