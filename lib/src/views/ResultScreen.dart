import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/controllers/ResultController.dart';
import 'package:gmaps_scraper_app/src/models/City.dart';
import 'package:gmaps_scraper_app/src/models/Keyword.dart';

class ResultScreen extends GetView<ResultController> {
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
          title: Text('Kết Quả'),
        ),
        body: ListView(
          padding: EdgeInsets.all(24.0),
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Từ khoá',
              ),
              value: controller.keyword != null ? controller.keyword!() : null,
              items: controller.keywords().map((Keyword item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.name!),
                );
              }).toList(),
              onChanged: !controller.lauched
                  ? (Keyword? val) => controller.keyword!(val!)
                  : null,
            ),
            SizedBox(
              height: 16.0,
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Khu vực',
              ),
              value: controller.city != null ? controller.city!() : null,
              items: controller.cities().map((City item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.name!),
                );
              }).toList(),
              onChanged: !controller.lauched
                  ? (City? val) => controller.city!(val!)
                  : null,
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              children: [
                Expanded(
                  child: controller.path().isNotEmpty
                      ? Text.rich(
                          TextSpan(
                            text: 'Nơi lưu: ',
                            children: [
                              TextSpan(
                                text: controller.path(),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text('Chưa chọn nơi lưu'),
                ),
                SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  child: Text('Chọn'),
                  onPressed: !controller.lauched ? controller.pick : null,
                ),
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                child: Text('Xuất Excel'),
                onPressed: controller.path().isNotEmpty && !controller.lauched
                    ? () => controller.export()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
