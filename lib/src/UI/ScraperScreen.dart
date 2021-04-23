import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/Controllers/Controllers.dart';
import 'package:gmaps_scraper_app/src/Models/Models.dart';
import 'package:gmaps_scraper_app/src/UI/Components/Components.dart';

class ScraperScreen extends GetView<ScraperController> {
  final MainController mainController = Get.find<MainController>();

  Widget get _bottomNavigationBar {
    return BottomAppBar(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 14.0,
        ),
        child: Row(
          children: [
            ElevatedButton(
              child: Text('Bắt đầu'.toUpperCase()),
              onPressed: controller.running.value == null
                  ? () => controller.run()
                  : null,
            ),
            SizedBox(
              width: 8.0,
            ),
            ElevatedButton(
              child: (controller.running.value ?? false)
                  ? Text('Tạm dừng'.toUpperCase())
                  : Text('Tiếp tục'.toUpperCase()),
              onPressed: controller.running.value != null
                  ? () => controller.toggleRunning()
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) => Colors.orange,
                ),
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            ElevatedButton(
              child: Text('Huỷ quét'.toUpperCase()),
              onPressed: controller.running.value != null
                  ? () => controller.close()
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) => Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Từ khoá: ',
                      children: [
                        TextSpan(
                          text: '${controller.totalInput} t.khoá',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Tổng h.tại: ',
                      children: [
                        TextSpan(
                          text: '${controller.totalResult} k.quả',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Text('Công Cụ'),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: controller.keywordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nội dung cần tìm',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded),
                            onPressed: () => controller.addKeyword(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      controller.keywordList.length > 0
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(
                                controller.keywordList.length,
                                (int index) => Chip(
                                  label: Text(controller.keywordList[index]),
                                  onDeleted: () {
                                    controller.keywordList.removeAt(index);
                                  },
                                ),
                              ),
                            )
                          : Alert('Chưa có từ khoá nào.'),
                      SizedBox(
                        height: 16.0,
                      ),
                      DropdownButtonFormField<Province>(
                        decoration: InputDecoration(
                          labelText: 'Khu vực liên quan',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              controller.province.value = null;
                            },
                          ),
                        ),
                        icon: SizedBox(),
                        value: controller.province.value,
                        items: mainController.listProvince
                            .map(
                              (Province item) => DropdownMenuItem<Province>(
                                value: item,
                                child: Text(item.name!),
                              ),
                            )
                            .toList(),
                        onChanged: (Province? val) async {
                          await mainController.fetchDistrict(val!.id!);

                          controller.province.value = val;
                          controller.district.value = null;
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      DropdownButtonFormField<District>(
                        decoration: InputDecoration(
                          labelText: 'Quận huyện liên quan',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded),
                            onPressed: () => controller.addRegion(),
                          ),
                        ),
                        icon: SizedBox(),
                        value: controller.district.value,
                        items: (controller.province.value?.districts ?? [])
                            .map(
                              (District item) => DropdownMenuItem<District>(
                                value: item,
                                child: Text(item.name!),
                              ),
                            )
                            .toList(),
                        onChanged: (District? val) {
                          controller.district.value = val;
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      controller.regionList.length > 0
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(
                                controller.regionList.length,
                                (int index) => Chip(
                                  label: Text(controller.regionList[index]),
                                  onDeleted: () {
                                    controller.regionList.removeAt(index);
                                  },
                                ),
                              ),
                            )
                          : Alert('Chưa có khu vực nào.'),
                    ],
                  ),
                ),
                SwitchListTile(
                  value: controller.advanced.value,
                  onChanged: (bool? val) => controller.advanced.value = val!,
                  title: Text('Quét nâng cao'),
                  subtitle: Text(
                    'Thu thập thêm email và số điện thoại từ nguồn khác.',
                  ),
                ),
                SwitchListTile(
                  value: controller.showUI.value,
                  onChanged: (bool? val) => controller.showUI.value = val!,
                  title: Text('Hiển thị giao diện'),
                ),
              ],
            ),
            Visibility(
              visible: controller.running.value != null,
              child: Positioned(
                child: Container(
                  color: Colors.black87,
                  child: ListView.separated(
                    controller: controller.scrollController,
                    padding: EdgeInsets.all(16.0),
                    itemCount: controller.logList.length,
                    itemBuilder: (_, int index) {
                      final String _logAt = DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(
                        controller.logList[index].logAt!,
                      );

                      String _level;
                      Color _color;

                      switch (controller.logList[index].level) {
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
                              text: controller.logList[index].message,
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
              ),
            ),
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar,
      ),
    );
  }
}
