import 'package:get/get.dart';
import 'package:flutter/material.dart';

class GMapsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto Mono',
      ),
      getPages: [],
    );
  }
}
