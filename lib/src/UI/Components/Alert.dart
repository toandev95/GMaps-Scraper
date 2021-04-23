import 'package:get/get.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Alert extends StatelessWidget {
  String text;

  Alert(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.accentColor.withOpacity(0.5),
        ),
        color: Get.theme.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(text),
    );
  }
}
