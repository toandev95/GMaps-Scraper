import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_scraper_app/src/components/components.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({Key? key}) : super(key: key);

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
        title: Text('Thiết Lập'.toUpperCase()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          CustomTextField(
            controller: controller.chromePathTextCtrl,
            labelText: 'Đường dẫn Chrome',
          ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomTextField(
                  controller: controller.maxResultTextCtrl,
                  keyboardType: TextInputType.number,
                  labelText: 'Kết quả tối đa',
                  hintText: 'Số lượng kết quả tối đa thu thập / từ khóa.',
                ),
              ),
              const SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: CustomTextField(
                  controller: controller.timeoutTextCtrl,
                  keyboardType: TextInputType.number,
                  labelText: 'Giới hạn thời gian',
                  hintText: 'Dừng tìm kiếm nếu thời gian chờ lâu hơn.',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomTextField(
            controller: controller.proxyTextCtrl,
            labelText: 'Máy chủ Proxy',
            hintText: 'socks5://user:pass@127.0.0.1:8080',
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
                  child: Text('Lưu lại'.toUpperCase()),
                  onPressed: () {
                    controller.handleSave();
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
