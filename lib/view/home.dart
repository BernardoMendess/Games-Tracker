import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final VoidCallback signOut;
  Home(this.signOut);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  signOut() {
   setState(() {
     widget.signOut();
   });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
           IconButton(
             onPressed: () {
                signOut();
             },
             icon: Icon(Icons.lock_open),
           )
         ],
      ),
      body: Center(
        child: Text("Home Page"),
      ),
    );
  }
}