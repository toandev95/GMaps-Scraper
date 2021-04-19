import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:gmaps_scraper_app/src/controllers/WelcomeController.dart';

class WelcomeScreen extends GetView<WelcomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(
                top: 12.0,
                right: 12.0,
              ),
              child: TextButton(
                child: Text('Chép mã'.toUpperCase()),
                onPressed: () => controller.copy(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(
                    size: 120.0,
                  ),
                  SizedBox(
                    height: 14.0,
                  ),
                  Text(
                    'Công cụ thu thập địa điểm Google Maps.'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 20.0,
              margin: EdgeInsets.only(
                bottom: 24.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  controller.loading()
                      ? Container(
                          width: 20.0,
                          height: 20.0,
                          margin: EdgeInsets.only(
                            right: 16.0,
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : SizedBox(),
                  Text(controller.message()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
