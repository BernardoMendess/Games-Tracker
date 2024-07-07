import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }

}

class HomeState extends State<Home>{

  String _text = "Exemplo ";
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text("App Bar - Stateful"),
        backgroundColor: (Colors.blue),
    ),
    body: Center( child: Container(
      child: Column(children: [
        Text(_text + counter.toString(),
        style: TextStyle(fontSize: 30),),
        ElevatedButton(onPressed: (){
          setState(() {
            counter++;          
            });
        }, 
        child: Text("Clique aqui"),
        )
      ],
      ),
      ),
      ),
    bottomNavigationBar: BottomAppBar(
      color: Colors.lightGreen,
      child: Text("Text"),
    ),
    );
  }

}