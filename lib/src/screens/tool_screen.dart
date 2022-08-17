import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/components/components.dart';
import 'package:gmaps_scraper_app/src/controllers/controllers.dart';

class ToolScreen extends GetView<ToolController> {
  const ToolScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Công Cụ Thu Thập'.toUpperCase()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          CustomTextField(
            controller: controller.labelTextCtrl,
            labelText: 'Thư mục',
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomTextField(
            controller: controller.keywordTextCtrl,
            labelText: 'Từ khóa tìm kiếm',
            minLines: 4,
            maxLines: 6,
            hintText: <String>[
              'Ví dụ:',
              'Quán cà phê gần Sài Gòn',
              'Trà sữa gần Quận 7, Sài Gòn',
            ].join('\n'),
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
                  child: Text('Bắt đầu'.toUpperCase()),
                  onPressed: () {
                    controller.handleRun();
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
