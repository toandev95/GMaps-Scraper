import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? labelText;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool isRequired;

  const CustomTextField({
    Key? key,
    this.controller,
    this.keyboardType,
    this.labelText,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Get.theme.primaryColor,
          ),
        ),
        // labelText: labelText,
        label: Text.rich(
          TextSpan(
            text: labelText,
            children: <TextSpan>[
              if (isRequired)
                const TextSpan(
                  text: ' *',
                ),
            ],
          ),
        ),
        hintText: hintText,
        alignLabelWithHint: true,
      ),
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}
