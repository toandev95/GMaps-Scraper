import 'package:get/get.dart';
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';

import 'package:gmaps_scraper_app/src/models/LicenseKey.dart';
import 'package:gmaps_scraper_app/src/screens/GMapsScreen.dart';
import 'package:gmaps_scraper_app/src/screens/ExportScreen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AesCrypt _crypt = AesCrypt();

  LicenseKey? _lc;

  int _currentTab = 0;

  int get currentTab => _currentTab;

  set currentTab(int index) {
    Get.back();

    setState(() {
      _currentTab = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _initScreen();
  }

  void _initScreen() async {
    _crypt.setPassword('1234qwer');

    final String _licenseText = await _crypt.decryptTextFromFile(
      'license.key',
    );
    _lc = LicenseKey.fromString(_licenseText);

    setState(() {});
  }

  void _call() async {
    Get.back();

    try {
      final String _zalo = 'https://zalo.me/0849181883';

      if (await canLaunch(_zalo)) {
        await launch(_zalo);
      }
    } catch (e) {
      Get.rawSnackbar(
        message: 'Không thể mở liên kết.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              accountName: Text(_lc?.fullName ?? '---'),
              accountEmail: Text(_lc?.email ?? '---'),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    selected: currentTab == 0,
                    leading: Icon(Icons.map_rounded),
                    title: Text('Quét bản đồ'),
                    onTap: () => currentTab = 0,
                  ),
                  ListTile(
                    selected: currentTab == 1,
                    leading: Icon(Icons.table_chart_rounded),
                    title: Text('Kết quả'),
                    onTap: () => currentTab = 1,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.support_agent_rounded),
                    trailing: Icon(Icons.open_in_browser_rounded),
                    title: Text('Liên hệ'),
                    onTap: () => _call(),
                  ),
                  ListTile(
                    title: Text('Hạn dùng'),
                    subtitle: Text(
                      _lc != null && _lc!.expiryDate != null
                          ? DateFormat.yMMMEd('vi').format(_lc!.expiryDate!)
                          : '---',
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
          switch (currentTab) {
            case 1:
              return ExportScreen();
            default:
              return GMapsScreen();
          }
        },
      ),
    );
  }
}
