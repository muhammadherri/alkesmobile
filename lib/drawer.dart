import 'package:flutter/material.dart';

import 'main.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  _NavDrawerState({this.nama,this.username});
final String nama;
final String username;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
new Padding(
            padding: new EdgeInsets.only(top: 40.0),
          ),
          ListTile(
            leading: Icon(Icons.input,color: Colors.red),
            title: Text('Logout',style: TextStyle(color: Colors.red),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          
        ],
      ),
    );
  }
}
