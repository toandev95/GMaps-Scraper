import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

import 'package:gmaps_scraper_app/src/controllers/HomeController.dart';
import 'package:gmaps_scraper_app/src/models/City.dart';
import 'package:gmaps_scraper_app/src/models/LogItem.dart';

class HomeScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: Text('Quét Bản Đồ'),
        ),
        body: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.keywordCtrl,
                enabled: !controller.lauched,
                decoration: InputDecoration(
                  labelText: 'Từ khoá quét',
                  errorText:
                      controller.error().isNotEmpty ? controller.error() : null,
                ),
                onFieldSubmitted: !controller.lauched
                    ? (String val) => controller.launch()
                    : null,
              ),
              SizedBox(
                height: 16.0,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Khu vực tìm kiếm',
                ),
                value: controller.city != null ? controller.city!() : null,
                items: controller.cities().map((City item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.name!),
                  );
                }).toList(),
                onChanged: controller.initialized
                    ? (City? val) => controller.city!(val!)
                    : null,
              ),
              SizedBox(
                height: 24.0,
              ),
              Row(
                children: [
                  ElevatedButton(
                    child: Text('Chạy'),
                    onPressed: !controller.lauched ? controller.launch : null,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    child: Text('Dừng'),
                    onPressed: controller.lauched ? controller.close : null,
                  ),
                ],
              ),
              SizedBox(
                height: 32.0,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor('#24232D'),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: ListView.separated(
                    controller: controller.scrollController,
                    // reverse: true,
                    padding: EdgeInsets.all(16.0),
                    itemCount: controller.logs().length,
                    itemBuilder: (_, int index) {
                      final String _logAt = DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(
                        controller.logs()[index].logAt!,
                      );

                      String _level;
                      Color _color;

                      switch (controller.logs()[index].level) {
                        case LogLevel.WARNING:
                          _level = 'CẢNH BÁO';
                          _color = Colors.lime;
                          break;
                        case LogLevel.ERROR:
                          _level = 'LỖI';
                          _color = Colors.red;
                          break;
                        default:
                          _level = 'THÔNG TIN';
                          _color = Colors.cyan;
                      }

                      return Text.rich(
                        TextSpan(
                          text: '\$ ',
                          children: [
                            TextSpan(
                              text: '[$_level] ',
                            ),
                            TextSpan(
                              text: '[$_logAt] ',
                            ),
                            TextSpan(
                              text: controller.logs()[index].message,
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: _color,
                        ),
                      );
                    },
                    separatorBuilder: (_, int index) {
                      return SizedBox(
                        height: 8.0,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
