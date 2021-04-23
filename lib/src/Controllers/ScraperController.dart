import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:puppeteer/puppeteer.dart' hide Dialog;
import 'package:flutter/material.dart' hide Dialog, Page, Key;

import 'package:gmaps_scraper_app/src/Models/Models.dart';
import 'package:gmaps_scraper_app/src/UI/Components/Components.dart';
import 'package:gmaps_scraper_app/src/Services/Services.dart';

class ScraperController extends GetxController {
  final DatabaseService databaseService = Get.find<DatabaseService>();

  final ScrollController scrollController = ScrollController();

  final Rxn<Province> province = Rxn<Province>();
  final Rxn<District> district = Rxn<District>();

  final RxList<String> keywordList = RxList<String>.empty();
  final RxList<String> regionList = RxList<String>.empty();

  final RxList<LogItem> logList = RxList<LogItem>.empty();

  final TextEditingController keywordCtrl = TextEditingController();

  final RxBool advanced = RxBool(false);
  final RxBool showUI = RxBool(false);

  final RxnBool running = RxnBool();

  final RxInt totalInput = RxInt(0);
  final RxInt totalResult = RxInt(0);

  Browser? browser;

  List<String> get inputList {
    final List<String> _ls = <String>[];

    keywordList.forEach((String k) {
      regionList.forEach((String r) {
        _ls.add('$k $r');
      });
    });

    totalInput.value = _ls.length;

    return _ls;
  }

  Database get db => databaseService.db!;

  @override
  void onInit() {
    debounce(logList, (_) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });

    super.onInit();
  }

  void addKeyword() {
    if (keywordCtrl.text.isEmpty) {
      Dialog.alert('Vui lòng nhập từ khoá cần tìm.');
    } else {
      final String _text = keywordCtrl.text;

      if (keywordList.contains(_text)) {
        Dialog.alert('Từ khoá bạn nhập đã có trong danh sách.');
      } else {
        keywordCtrl.clear();
        keywordList.add(_text);
      }
    }
  }

  void addRegion() {
    if (district.value == null || province.value == null) {
      Dialog.alert('Không được để trống thông tin khu vực.');
    } else {
      final String _text = '${district.value!.name} ${province.value!.name}';

      if (regionList.contains(_text)) {
        Dialog.alert('Khu vực đã có trong danh sách.');
      } else {
        regionList.add(_text);
      }
    }
  }

  void run() async {
    running.value = true;

    await gmaps();

    await Future.delayed(
      Duration(
        seconds: 2,
      ),
    );

    close();
  }

  void toggleRunning() {
    if (running.value == true) {
      running.value = false;
    } else {
      running.value = true;
    }
  }

  void close() async {
    running.value = null;

    await browser?.close();
    browser = null;
  }

  Future<void> gmaps([int index = 0]) async {
    if (browser == null) {
      browser = await puppeteer.launch(
        headless: false,
        args: [
          // '--app=https://maps.google.com',
          '--window-size=1024,700',
          '--no-sandbox',
        ],
        defaultViewport: DeviceViewport(
          height: 3000,
          width: 1020,
          hasTouch: true,
          isMobile: true,
        ),
      );

      await browser!.browserContexts.first.overridePermissions(
        'https://maps.google.com',
        [
          PermissionType.geolocation,
          PermissionType.notifications,
        ],
      );
    }

    final Page _page = (await browser!.pages)[0];
    _page.defaultTimeout = Duration(
      minutes: 3,
    );
    await _page.setExtraHTTPHeaders({
      'Accept-Language': 'vi',
    });
    await _page.goto(
      'https://maps.google.com',
      wait: Until.networkAlmostIdle,
    );

    await _page.type(
      '#searchboxinput',
      inputList[index],
      delay: Duration(
        milliseconds: 50,
      ),
    );
    await Future.delayed(
      Duration(
        milliseconds: 500,
      ),
    );
    await _page.keyboard.press(Key.enter);
    await _page.waitForSelector(
      '.section-layout.section-scrollbox',
      visible: true,
    );

    await link(_page);

    if (index < (inputList.length - 1)) {
      return gmaps(index + 1);
    }

    return Future.delayed(
      Duration(
        seconds: 1,
      ),
    );
  }

  Future<void> link(Page page, [int index = 0, int tries = 0]) async {
    await Future.delayed(
      Duration(
        milliseconds: 300,
      ),
    );

    if (page.isClosed) {
      return;
    }

    if (running.value == false) {
      await Future.delayed(
        Duration(
          seconds: 5,
        ),
      );

      return link(page, index);
    }

    final List<ElementHandle> _elms = await page.$$(
      'div[jsan*="__content-container-is-link"]',
    );

    if (_elms.length == 0) {
      return;
    }

    await Future.delayed(
      Duration(
        milliseconds: 500,
      ),
    );

    final ElementHandle _elm = _elms[index];

    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );

    try {
      await $click(page, _elm);

      await page.waitForSelector(
        '.section-hero-header-title-title',
      );
    } catch (e) {
      return link(page, index + 1);
    }

    final String? _title = await value(
      page,
      '.section-hero-header-title-title',
    );
    final String? _category = await value(
      page,
      'button.widget-pane-link[jsaction="pane.rating.category"]',
    );
    final String _star = await value(
      page,
      'span[class*="section-star-display"]',
    ).then(
      (val) => val != null ? val.replaceAll(',', '.').trim() : '0',
    );
    final String _review = await value(
      page,
      'button.widget-pane-link[jsaction="pane.rating.moreReviews"]',
    ).then(
      (val) => val != null && val.contains(' ')
          ? val.split(' ')[0].replaceAll('.', '').trim()
          : '0',
    );
    final List<String> _editorials = await values(
      page,
      'div.section-editorial-attribute-text',
    );
    final String? _address = await value(
      page,
      'button[data-item-id="address"] .gm2-body-2',
    );
    final String? _phone = await value(
      page,
      'button[data-item-id*="phone:tel"] .gm2-body-2',
    );
    final String? _rawHour = await value(
      page,
      'span[class*="info-hour-text"]',
    );

    final Result _result = Result();

    if (_rawHour != null && _rawHour.contains(':')) {
      final String _hour = _rawHour.split(':')[1].trim();

      _result.hour = _hour;
    }

    final ElementHandle? _imgElm = await page.$OrNull(
      'button.section-hero-header-image-hero img',
    );

    if (_imgElm != null) {
      final String _img = await _imgElm.evaluate(
        'node => node.getAttribute("src")',
      );

      _result.imageUrl = _img;
    }

    final String _keyword = keywordCtrl.text;

    _result.url = page.url;
    _result.title = _title;
    _result.star = double.parse(_star);
    _result.review = int.parse(_review);
    _result.address = _address;
    _result.phone = _phone;

    if (_keyword.isNotEmpty) {
      final List<Map<String, Object?>> _results = await db.query(
        'keywords',
        where: 'name = ?',
        whereArgs: [_keyword],
        limit: 1,
      );

      if (_results.length == 0) {
        _result.keywordId = await db.insert(
          'keywords',
          {'name': _keyword},
        );
      } else {
        _result.keywordId = _results.first['id'] as int;
      }
    }

    if (_category != null) {
      final List<Map<String, Object?>> _results = await db.query(
        'categories',
        where: 'name = ?',
        whereArgs: [_category],
        limit: 1,
      );

      if (_results.length == 0) {
        _result.categoryId = await db.insert(
          'categories',
          {'name': _category},
        );
      } else {
        _result.categoryId = _results.first['id'] as int;
      }
    }

    _result.editorialIds = await Future.wait(
      _editorials.map((String val) async {
        final List<Map<String, Object?>> _results = await db.query(
          'editorials',
          where: 'name = ?',
          whereArgs: [val],
          limit: 1,
        );

        if (_results.length == 0) {
          return await db.insert(
            'editorials',
            {'name': val},
          );
        }

        return _results.first['id'] as int;
      }).toList(),
    );

    _result.createdAt = DateTime.now();

    final int _resultId = await db.insert(
      'results',
      {
        'keyword_id': _result.keywordId,
        'province_id': _result.provinceId,
        'url': _result.url,
        'image_url': _result.imageUrl,
        'title': _result.title,
        'category_id': _result.categoryId,
        'star': _result.star,
        'review': _result.review,
        'address': _result.address,
        'phone': _result.phone,
        'hour': _result.hour,
        'created_at': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(_result.createdAt!),
      }.map(
        (key, value) => MapEntry(
          key,
          value != null ? '$value' : 'NULL',
        ),
      ),
    );
    await Future.wait(
      _result.editorialIds!.map((int id) async {
        await db.insert('editorial_result', {
          'editorial_id': id,
          'result_id': _resultId,
        });
      }).toList(),
    );

    await Future.delayed(
      Duration(
        milliseconds: 500,
      ),
    );

    await $click(
      page,
      '.section-back-to-list-button',
    );

    await page.waitForNavigation(
      wait: Until.networkAlmostIdle,
    );
    await page.waitForSelector(
      'a.place-result-container-place-link',
    );

    await Future.delayed(
      Duration(
        milliseconds: 500,
      ),
    );

    if (index == (_elms.length - 1)) {
      final List<ElementHandle> _nlms = await page.$x(
        '//*[@jsaction="pane.paginationSection.nextPage"][not(@disabled)]',
      );
      if (_nlms.length == 0) {
        return;
      }

      await $click(page, _nlms.first);

      await page.waitForNavigation(
        wait: Until.networkAlmostIdle,
      );
      await Future.delayed(
        Duration(
          seconds: 1,
        ),
      );

      return link(page);
    }

    return link(page, index + 1);
  }

  Future<String?> value(Page page, String selector) async {
    final ElementHandle? _elm = await page.$OrNull(selector);

    if (_elm == null) {
      return null;
    }

    final String _val = await _elm.evaluate(
      'node => node.innerText',
    );

    return _val.isNotEmpty ? _val.trim() : null;
  }

  Future<List<String>> values(Page page, String selector) async {
    final List<ElementHandle> _elms = await page.$$(selector);

    if (_elms.length == 0) {
      return [];
    }

    final List<String> _results = <String>[];

    await Future.wait(
      _elms.map((ElementHandle elm) async {
        final String _val = await elm.evaluate(
          'node => node.innerText',
        );

        if (_val.trim().isNotEmpty) {
          _results.add(_val);
        }

        return;
      }).toList(),
    );

    return _results;
  }

  Future<void> $click(Page page, dynamic selector, [int tries = 0]) async {
    try {
      if (selector.runtimeType == String) {
        await page.tap(selector);
      } else if (selector.runtimeType == ElementHandle) {
        final ElementHandle _elm = (selector as ElementHandle);

        await _elm.focus();
        await _elm.tap();
      }
    } catch (e) {
      if (tries > 3) {
        throw e;
      } else {
        await Future.delayed(
          Duration(
            seconds: 1,
          ),
        );

        return $click(page, selector, tries + 1);
      }
    }
  }
}
