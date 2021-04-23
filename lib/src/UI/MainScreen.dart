import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/Controllers/Controllers.dart';
import 'package:gmaps_scraper_app/src/UI/UI.dart';

class MainScreen extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(controller.currentUser.name!),
                accountEmail: Text(controller.currentUser.email!),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.map_rounded),
                      title: Text('Công Cụ'),
                      onTap: () => controller.toTab(0),
                      selected: controller.currentIndex.value == 0,
                    ),
                    ListTile(
                      leading: Icon(Icons.table_chart_rounded),
                      title: Text('Kết Quả'),
                      onTap: () => controller.toTab(1),
                      selected: controller.currentIndex.value == 1,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.support_agent_rounded),
                      trailing: Icon(Icons.open_in_browser),
                      title: Text('Hỗ Trợ'),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('Hạn Dùng'),
                      subtitle: Text(
                        DateFormat.yMEd().format(
                          controller.currentUser.expiresAt!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (_) {
            switch (controller.currentIndex.value) {
              case 1:
                return ExportScreen();
              default:
                return ScraperScreen();
            }
          },
        ),
      ),
    );
  }
}
