import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_scraper_app/src/components/components.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({Key? key}) : super(key: key);

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kích Hoạt Bản Quyền'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          CustomTextField(
            controller: appController.emailTextCtrl,
            labelText: 'Email',
            isRequired: true,
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomTextField(
            controller: appController.licenseTextCtrl,
            minLines: 4,
            maxLines: 6,
            labelText: 'Khóa bản quyền',
            isRequired: true,
          ),
          const SizedBox(
            height: 32.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 140.0,
                height: 38.0,
                child: ElevatedButton(
                  child: Text('Kích hoạt'.toUpperCase()),
                  onPressed: () {
                    appController.handleActivation();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
