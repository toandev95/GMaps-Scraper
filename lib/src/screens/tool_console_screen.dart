import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/utils/extensions.dart';

class ToolConsoleScreen extends GetView<ToolController> {
  const ToolConsoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: const Text('Theo Dõi Thu Thập'),
        ),
        body: Obx(
          () => ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(24.0),
            itemCount: controller.logs.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                ),
                child: Text.rich(
                  TextSpan(
                    text: r'$  ',
                    children: <TextSpan>[
                      TextSpan(
                        text: '[${controller.logs[index].createdAt.format()}] ',
                      ),
                      TextSpan(
                        text: controller.logs[index].text,
                        style: const TextStyle(
                          color: Colors.lime,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () async {
        await controller.handleClose();

        return true;
      },
    );
  }
}
