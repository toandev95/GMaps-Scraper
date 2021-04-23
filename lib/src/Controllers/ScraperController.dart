import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gmaps_scraper_app/src/Models/Models.dart';

class ScraperController extends GetxController {
  final Rxn<Province> province = Rxn<Province>();
  final Rxn<District> district = Rxn<District>();

  final RxList<String> keywordList = RxList<String>.empty();
  final RxList<String> regionList = RxList<String>.empty();

  final TextEditingController keywordCtrl = TextEditingController();

  final RxBool advanced = RxBool(false);
  final RxBool showUI = RxBool(false);

  void addKeyword() {
    if (keywordCtrl.text.isEmpty) {
      return;
    }

    final String _text = keywordCtrl.text;

    if (keywordList.contains(_text)) {
      return;
    }

    keywordCtrl.clear();
    keywordList.add(_text);
  }

  void addRegion() {
    if (district.value == null || province.value == null) {
      return;
    }

    final String _text = '${district.value!.name} ${province.value!.name}';

    if (regionList.contains(_text)) {
      return;
    }

    regionList.add('${district.value!.name} ${province.value!.name}');
  }
}
