import 'dart:io';

import 'package:get/get.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:flutter/material.dart' hide Page, Key;
import 'package:sqflite_common/sqlite_api.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:rome_bus/rome_bus.dart';

import 'package:gmaps_scraper_app/src/events/KeywordAddedEvent.dart';
import 'package:gmaps_scraper_app/src/models/Result.dart';
import 'package:gmaps_scraper_app/src/models/LogItem.dart';
import 'package:gmaps_scraper_app/src/models/City.dart';
import 'package:gmaps_scraper_app/src/services/DbService.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final TextEditingController keywordCtrl = TextEditingController();

  final RxList<City> cities = <City>[].obs;
  final RxList<LogItem> logs = <LogItem>[].obs;

  final RxString error = ''.obs;
  final RxBool scraping = false.obs;

  Browser? browser;

  Rx<City>? city;

  DbService dbService;

  HomeController(this.dbService);

  @override
  bool get initialized => super.initialized && city != null;

  Database get db => dbService.instance!;

  bool get lauched => super.initialized && scraping();

  @override
  void onInit() async {
    super.onInit();

    logs.add(
      LogItem.info('Đang kiểm tra tương thích hệ thống.'),
    );

    try {
      await db.query('cities').then((List<Map<String, Object?>> _results) {
        _results.forEach((Map<String, Object?> city) {
          cities.add(
            City(
              id: (city['id'] as int),
              name: (city['name'] as String),
            ),
          );
        });

        if (cities().length > 0) {
          city = cities().first.obs;
        } else {
          throw Error();
        }
      });
    } catch (e) {
      print(e);

      await Get.dialog(
        AlertDialog(
          content: Text('Sự cố phân tích cơ sở dữ liệu.'),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => exit(0),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }

    logs.add(
      LogItem.info('Sẵn sàng quét và lưu trữ.'),
    );
  }

  @override
  void onClose() {
    close();

    super.onClose();
  }

  void launch() async {
    error('');

    if (keywordCtrl.text.isEmpty) {
      error('Chưa nhập từ khoá cần tìm!');

      return;
    }

    await gmaps();
  }

  Future<void> close() async {
    scraping(false);

    await browser?.close();
    browser = null;

    logs.add(
      LogItem.warning('Đã đóng trình thu thập.'),
    );
  }

  Future<void> gmaps() async {
    scraping(true);

    logs.add(
      LogItem.info('Đang mở trình thu thập.'),
    );

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

    final Page _page = (await browser!.pages)[0];
    _page.defaultTimeout = Duration(
      minutes: 3,
    );
    await _page.setExtraHTTPHeaders(
      {
        'Accept-Language': 'vi',
      },
    );
    await _page.goto(
      'https://maps.google.com',
      wait: Until.networkAlmostIdle,
    );

    logs.add(
      LogItem.info('Đang gõ từ khoá tìm kiếm.'),
    );
    await _page.type(
      '#searchboxinput',
      '${keywordCtrl.text}, ${city!.value.name}',
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

    await Future.wait([
      // _page.waitForNavigation(
      //   wait: Until.networkAlmostIdle,
      // ),
      _page.waitForSelector(
        '.section-layout.section-scrollbox',
        visible: true,
      ),
    ]);

    logs.add(
      LogItem.info('Bắt đầu thu thập dữ liệu.'),
    );

    await link(_page);

    await Future.delayed(
      Duration(
        seconds: 3,
      ),
    );

    await close();

    logs.add(
      LogItem.info('Kết thúc thu thập dữ liệu.'),
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

    final List<ElementHandle> _elms = await page.$$(
      // '//div[contains(@class, "__content-container")]',
      'div[jsan*="__content-container-is-link"]',
    );

    // print(_elms.length);

    if (_elms.length == 0) {
      return;
    }

    logs.add(
      LogItem.info('Đang lấy địa điểm thứ ${index + 1}'),
    );

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

        RomeBus.getBus().send(KeywordAddedEvent());
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
      }),
    );

    _result.cityId = city!.value.id;
    _result.createdAt = DateTime.now();

    final int _resultId = await db.insert('results', _result.toMapSQL());
    await Future.wait(
      _result.editorialIds!.map((int id) async {
        await db.insert('editorial_result', {
          'editorial_id': id,
          'result_id': _resultId,
        });
      }),
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
      logs.add(
        LogItem.info('Đã lấy tổng cộng ${_elms.length} địa điểm.'),
      );

      final List<ElementHandle> _nlms = await page.$x(
        '//*[@jsaction="pane.paginationSection.nextPage"][not(@disabled)]',
      );
      if (_nlms.length == 0) {
        return;
      }

      logs.add(
        LogItem.info('Chuyển qua trang kết quả kế tiếp.'),
      );

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
      // print(selector);

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

  void scrollToBottom() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }
}
