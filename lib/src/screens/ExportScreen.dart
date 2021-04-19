import 'package:flutter/material.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
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
        title: Text('Xuất Dữ Liệu'),
      ),
    );
  }
}
