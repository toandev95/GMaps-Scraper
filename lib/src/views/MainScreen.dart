import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/controllers/MainController.dart';
import 'package:gmaps_scraper_app/src/views/HomeScreen.dart';
import 'package:gmaps_scraper_app/src/views/ResultScreen.dart';

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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.zero,
                accountName: Text('Toàn Đoàn'),
                accountEmail: Text('toandev.95@gmail.com'),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      selected: controller.tabIndex.value == 0,
                      leading: Icon(Icons.map_rounded),
                      title: Text('Quét bản đồ'),
                      onTap: () => controller.tab(0),
                    ),
                    ListTile(
                      selected: controller.tabIndex.value == 1,
                      leading: Icon(Icons.table_chart_rounded),
                      title: Text('Kết quả'),
                      onTap: () => controller.tab(1),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.support_agent_rounded),
                      trailing: Icon(Icons.open_in_browser_rounded),
                      title: Text('Liên hệ'),
                      onTap: () => controller.zalo(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (_) {
            switch (controller.tabIndex.value) {
              case 1:
                return ResultScreen();
              default:
                return HomeScreen();
            }
          },
        ),
      ),
    );
  }
}
