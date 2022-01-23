import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/screens/screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AppController appController = Get.find<AppController>();

  int _currentIndex = 0;

  String get appName => appController.packageInfo.appName;
  String get appVersion => appController.packageInfo.version;

  Widget _buildMenuItem({
    required int index,
    Icon? icon,
    required String title,
  }) =>
      ListTile(
        leading: icon,
        title: Text(title.toUpperCase()),
        onTap: () {
          setState(() {
            _currentIndex = index;
          });

          Get.back();
        },
        selected: _currentIndex == index,
      );

  void openSupport() async {
    await launch(supportUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(appName),
              accountEmail: Text(appVersion),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildMenuItem(
                    index: 0,
                    icon: const Icon(Icons.map_rounded),
                    title: 'Công Cụ Thu Thập',
                  ),
                  _buildMenuItem(
                    index: 1,
                    icon: const Icon(Icons.table_view_rounded),
                    title: 'Kết Quả Đã Lưu Lại',
                  ),
                  _buildMenuItem(
                    index: 2,
                    icon: const Icon(Icons.settings),
                    title: 'Thiết Lập',
                  ),
                  const Divider(),
                  ListTile(
                    trailing: const Icon(Icons.open_in_browser_rounded),
                    title: Text('Trợ Giúp & Phản Hồi'.toUpperCase()),
                    onTap: () => openSupport(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (_) {
          switch (_currentIndex) {
            case 0:
              return const ToolScreen();
            case 1:
              return const ResultScreen();
            case 2:
              return const SettingScreen();
            default:
              return Container();
          }
        },
      ),
    );
  }
}
