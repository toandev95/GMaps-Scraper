import 'package:flutter/material.dart';

class GMapsScreen extends StatefulWidget {
  @override
  _GMapsScreenState createState() => _GMapsScreenState();
}

class _GMapsScreenState extends State<GMapsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text('Thu Thập'),
      ),
    );
  }
}
