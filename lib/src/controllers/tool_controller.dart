import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter/material.dart' hide Page, Key;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_scraper_app/src/constants/constants.dart';
import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/screens/screens.dart';
import 'package:google_maps_scraper_app/src/models/models.dart';
import 'package:google_maps_scraper_app/src/utils/extensions.dart';

class ToolController extends GetxController {
  final AppController appController = Get.find<AppController>();

  final TextEditingController labelTextCtrl = TextEditingController();
  final TextEditingController keywordTextCtrl = TextEditingController();

  final RxList<LogItem> logs = RxList<LogItem>.empty();
  final List<String> keywords = <String>[];

  Page? currPage;
  int currKeywordIndex = 0;
  int currListItemIndex = 0;

  SharedPreferences get prefs => appController.prefs;

  String? get cfgChromePath => prefs.getString(StorageKeys.chromePath);
  int? get cfgMaxResult => prefs.getInt(StorageKeys.maxResult);
  int get cfgTimeout => prefs.getInt(StorageKeys.timeout) ?? 30;
  String? get cfgProxy => prefs.getString(StorageKeys.proxy);

  void log(String text) {
    logs.insert(0, LogItem.build(text));
  }

  void handleRun() async {
    final List<String> _keywords = keywordTextCtrl.text
        .split('\n')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty && s.length > 1)
        .toList();

    keywords.addAll(_keywords);

    if (cfgChromePath == null) {
      await EasyLoading.showToast(
        'Vui lòng thiết lập đường dẫn Chrome.',
      );
    } else if (keywords.isEmpty) {
      await EasyLoading.showToast(
        'Chưa nhập từ khóa cần thu thập.',
      );
    } else {
      await EasyLoading.show(
        status: 'Đang khởi tạo ...',
        dismissOnTap: false,
      );

      Get.to(
        () => const ToolConsoleScreen(),
        fullscreenDialog: true,
      );

      final Browser _browser = await puppeteer.launch(
        headless: false,
        executablePath: cfgChromePath,
        defaultViewport: const DeviceViewport(
          width: 800,
          height: 2700,
        ),
        args: <String>[
          '--window-size=800,600',
          '--no-sandbox',
          if (cfgProxy != null && cfgProxy!.isNotEmpty) //
            '--proxy-server=$cfgProxy',
        ],
        devTools: false,
      );

      await EasyLoading.dismiss();

      final Page _page = await _browser.newPage();
      currPage = _page;

      // _page.defaultTimeout = 2.minutes;
      _page.defaultTimeout = cfgTimeout.seconds;

      await _page.browserContext.overridePermissions(
        'https://www.google.com/maps',
        <PermissionType>[
          PermissionType.clipboardReadWrite,
          PermissionType.notifications,
        ],
      );

      await _run(_page);
    }
  }

  Future<void> handleClose() async {
    await _close();

    Get.back();
  }

  Future<void> _run(Page page) async {
    currListItemIndex = 0;

    log('Đang truy cập Google Maps.');

    await page.goto(
      'https://www.google.com/maps?hl=en',
      referrer: 'https://google.com',
      wait: Until.networkAlmostIdle,
    );

    log('Bắt đầu tìm kiếm thông tin từ khóa.');

    await page.type(
      '#searchboxinput',
      keywords[currKeywordIndex], // sdt5y2334590fd adsdioasud
      delay: 30.milliseconds,
    );

    await Future.delayed(1.seconds);

    await page.keyboard.press(Key.enter);

    await page.waitForSelector(
      'div[aria-label*="Results"]',
      visible: true,
    );
    await Future.delayed(2.seconds);

    final ElementHandle _sceneElm = await page.$('.id-scene');
    await _sceneElm.evaluate('node => node.remove()');

    log('Chuẩn bị thu thập các thông tin địa điểm.');

    await _loop(page);

    if (currKeywordIndex < keywords.length - 1) {
      currKeywordIndex++;

      return _run(page);
    } else {
      _close();
    }
  }

  Future<void> _loop(Page page) async {
    log('Lấy dữ liệu vị trí #$currListItemIndex.');

    final Result _result = Result(
      label: labelTextCtrl.text.isNotEmpty ? labelTextCtrl.text : null,
      keyword: keywords[currKeywordIndex],
      createdAt: DateTime.now(),
    );

    final List<ElementHandle> _elms = await page.$$(
      // '.section-scrollbox div[jsaction*="mouseover:pane"]',
      'div[aria-label*="Results"] div[jsaction*="mouseover:pane"]',
    );
    final ElementHandle _elm = _elms[currListItemIndex];

    await _elm.click();

    await Future.delayed(2.seconds);

    final ElementHandle? _titleElm = await page.$OrNull(
      'h1[class*="header-title-title"] span:nth-child(1)',
    );

    if (_titleElm != null) {
      final String? _title = await _titleElm.evaluate(
        'n => n.innerText || null',
      );

      if (_title != null && _title.isNotEmpty) {
        // print(_title);

        _result.title = _title;
      }
    }

    final ElementHandle? _subTitleElm = await page.$OrNull(
      'h1[class*="header-title-title"] span:nth-child(2)',
    );

    if (_subTitleElm != null) {
      final String? _subTitle = await _subTitleElm.evaluate(
        'n => n.innerText || null',
      );

      if (_subTitle != null && _subTitle.isNotEmpty) {
        // print(_subTitle);

        _result.subTitle = _subTitle;
      }
    }

    final ElementHandle? _starArrayElm = await page.$OrNull(
      '.section-star-array',
    );

    if (_starArrayElm != null) {
      final String? _starText = await _starArrayElm.evaluate(
        'n => n.parentNode.querySelector("span[aria-hidden=true]").innerText',
      );

      if (_starText != null && _starText.isNotEmpty) {
        // print(_starText);

        _result.star = double.tryParse(_starText);
      }
    }

    final ElementHandle? _totalReviewElm = await page.$OrNull(
      'button[jsaction="pane.rating.moreReviews"]',
    );

    if (_totalReviewElm != null) {
      final String? _totalReviewText = await _totalReviewElm.evaluate(
        'n => n.innerText || null',
      );

      if (_totalReviewText != null && _totalReviewText.isNotEmpty) {
        // print(_totalReviewText);

        _result.totalReview = int.tryParse(_totalReviewText.split(' ').first);
      }
    }

    final ElementHandle? _categoryElm = await page.$OrNull(
      'button[jsaction="pane.rating.category"]',
    );

    if (_categoryElm != null) {
      final String? _categoryName = await _categoryElm.evaluate(
        'n => n.innerText || null',
      );

      if (_categoryName != null && _categoryName.isNotEmpty) {
        // print(_categoryName);

        _result.categoryName = _categoryName;
      }
    }

    final ElementHandle? _attrElm = await page.$OrNull(
      'button[jsaction*="pane.attributes."]',
    );

    if (_attrElm != null) {
      final List<ElementHandle> _attrElms = await _attrElm.$$(
        'div[jsan*="text,"][class*="-text"]',
      );

      if (_attrElms.isNotEmpty) {
        final List<String> _attrs = <String>[];

        for (ElementHandle attrElm in _attrElms) {
          final String? _attrText = await attrElm.evaluate(
            'n => n.innerText || null',
          );

          if (_attrText != null) {
            _attrs.add(_attrText);
          }
        }

        if (_attrs.isNotEmpty) {
          // print(_attrs);

          _result.attributes = _attrs.map((String s) => s).toList();
        }
      }
    }

    final ElementHandle? _addressElm = await page.$OrNull(
      'button[data-item-id="address"] div[jsan*="gm2-body-2"][class*="text"]',
    );

    if (_addressElm != null) {
      final String? _addressText = await _addressElm.evaluate(
        'n => n.innerText || null',
      );

      if (_addressText != null && _addressText.isNotEmpty) {
        // print(_addressText);

        _result.address = _addressText;
      }
    }

    final ElementHandle? _openHoursElm = await page.$OrNull(
      'div[jsaction*="pane.openhours."] span[class*="hour-text"]',
    );

    if (_openHoursElm != null) {
      final String? _openHoursText = await _openHoursElm.evaluate(
        'n => n.innerText || null',
      );

      if (_openHoursText != null && _openHoursText.isNotEmpty) {
        // print(_openHoursText);

        _result.openHours = _openHoursText;
      }
    }

    final ElementHandle? _authorityElm = await page.$OrNull(
      'button[data-item-id="authority"]',
    );

    if (_authorityElm != null) {
      await _authorityElm.hover();

      final ElementHandle? _copyBtnElm = await page.$OrNull(
        'button[jsaction*="pane.focusTooltip"][jsaction*="keydown:pane"][aria-label*="web"] img[src*="copy"]',
      );

      if (_copyBtnElm != null) {
        await _copyBtnElm.click();

        await Future.delayed(1.seconds);

        final String? _clipboard = await page.evaluate(
          '''async () => {
            try {
              return await navigator.clipboard.readText();
            } catch (e) {
              return null;
            }
          }''',
        );

        if (_clipboard != null && _clipboard.isNotEmpty) {
          // print(_clipboard);

          _result.websiteUrl = _clipboard;
        }
      }
    }

    final ElementHandle? _phoneElm = await page.$OrNull(
      'button[data-item-id*="phone:tel"]',
    );

    if (_phoneElm != null) {
      final String? _phoneText = await _phoneElm.evaluate(
        'n => n.getAttribute("data-item-id")',
      );

      if (_phoneText != null &&
          _phoneText.isNotEmpty &&
          _phoneText.contains('tel:')) {
        // print(_phoneText.split('tel:')[1].trim());

        _result.phoneNumber = _phoneText.split('tel:')[1].trim();
      }
    }

    final ElementHandle? _heroImageElm = await page.$OrNull(
      'button[jsaction="pane.heroHeaderImage.click"] > img',
    );

    if (_heroImageElm != null) {
      final String? _imageUrl = await _heroImageElm.evaluate(
        'n => n.getAttribute("src")',
      );

      if (_imageUrl != null && _imageUrl.isNotEmpty) {
        // print(_imageUrl);

        _result.imageUrl = _imageUrl;
      }
    }

    if (_result.title != null && _result.address != null) {
      _result.key = md5
          .convert(utf8.encode('${_result.title!}+${_result.address}'))
          .toString();

      final ResultSet _res = appController.db.select(
        '''SELECT `id`
        FROM `results`
        WHERE `key` = "${_result.key}"
        LIMIT 1''',
      );

      if (_res.rows.isEmpty) {
        appController.db.prepare(
          '''INSERT INTO `results`
          (
            `key`,
            `label`,
            `keyword`,
            `title`,
            `sub_title`,
            `star`,
            `total_review`,
            `category_name`,
            `attributes`,
            `address`,
            `open_hours`,
            `website_url`,
            `phone_number`,
            `image_url`,
            `created_at`
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        ).execute([
          _result.key,
          _result.label,
          _result.keyword,
          _result.title,
          _result.subTitle,
          _result.star,
          _result.totalReview,
          _result.categoryName,
          (_result.attributes ?? []).join(','),
          _result.address,
          _result.openHours,
          _result.websiteUrl,
          _result.phoneNumber,
          _result.imageUrl,
          DateTime.now().toSQL(),
        ]);
      } else {
        appController.db.prepare(
          '''UPDATE `results`
          SET
            `label` = ?,
            `keyword` = ?,
            `title` = ?,
            `sub_title` = ?,
            `star` = ?,
            `total_review` = ?,
            `category_name` = ?,
            `attributes` = ?,
            `address` = ?,
            `open_hours` = ?,
            `website_url` = ?,
            `phone_number` = ?,
            `image_url` = ?,
            `updated_at` = ?
          WHERE `key` = "${_result.key}"''',
        ).execute([
          _result.label,
          _result.keyword,
          _result.title,
          _result.subTitle,
          _result.star,
          _result.totalReview,
          _result.categoryName,
          (_result.attributes ?? <String>[]).join(','),
          _result.address,
          _result.openHours,
          _result.websiteUrl,
          _result.phoneNumber,
          _result.imageUrl,
          DateTime.now().toSQL(),
        ]);
      }

      log('Lưu vào cơ sở dữ liệu vị trí #$currListItemIndex.');
    }

    await page.goBack();

    await page.waitForSelector(
      '.section-scrollbox div[jsaction*="mouseover:pane"]',
      visible: true,
    );

    await Future.delayed(1.seconds);

    if (cfgMaxResult != null && currListItemIndex >= (cfgMaxResult! - 1)) {
      log('Dừng thu thập do đạt kết quả tối đa.');

      currListItemIndex = 0;

      return Future.value();
    }

    if (currListItemIndex < _elms.length - 1) {
      currListItemIndex++;

      return _loop(page);
    } else {
      final ElementHandle? _nextElm = await page.$OrNull(
        'button[jsaction="pane.paginationSection.nextPage"]',
      );

      final bool _hasNextPage = _nextElm != null
          ? await _nextElm.evaluate('n => !n.hasAttribute("disabled")')
          : false;

      if (_hasNextPage) {
        logs.clear();

        log('Đang chuyển trang để thu thập danh sách tiếp theo.');

        await _nextElm.click();

        currListItemIndex = 0;

        return _loop(page);
      }
    }

    log('Hoàn tất thu thập dữ liệu.');
  }

  Future<void> _close() async {
    if (currPage != null) {
      log('Đang đóng trình duyệt.');

      await currPage!.browser.close();

      log('Đã đóng trình thu thập.');
    }

    keywords.clear();

    currPage = null;
    currKeywordIndex = 0;
  }
}
