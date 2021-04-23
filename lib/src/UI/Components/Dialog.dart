import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Dialog {
  static Future<void> alert(
    String message, {
    String? title,
  }) async {
    return Get.dialog(
      AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Đóng'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
