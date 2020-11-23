import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
 
  final Uri uri;
 
  FirstPage(this.uri);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text("This is first page")
      ),
      body: Container(child: Center(child: Text(uri.toString(), style: TextStyle(fontSize: 22),))));
  }
}