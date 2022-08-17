import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter/material.dart' hide Page, Key;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gmaps_scraper_app/src/constants/constants.dart';
import 'package:gmaps_scraper_app/src/controllers/controllers.dart';
import 'package:gmaps_scraper_app/src/screens/screens.dart';
import 'package:gmaps_scraper_app/src/models/models.dart';
import 'package:gmaps_scraper_app/src/utils/extensions.dart';

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
    final List<String> list = keywordTextCtrl.text
        .split('\n')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty && s.length > 1)
        .toList();

    keywords.addAll(list);

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

      final Browser browser = await puppeteer.launch(
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

      final Page page = await browser.newPage();
      currPage = page;

      // _page.defaultTimeout = 2.minutes;
      page.defaultTimeout = cfgTimeout.seconds;

      await page.browserContext.overridePermissions(
        'https://www.google.com/maps',
        <PermissionType>[
          PermissionType.clipboardReadWrite,
          PermissionType.notifications,
        ],
      );

      _run(page);
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

    final ElementHandle sceneElm = await page.$('.id-scene');
    await sceneElm.evaluate('node => node.remove()');

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

    final Result result = Result(
      label: labelTextCtrl.text.isNotEmpty ? labelTextCtrl.text : null,
      keyword: keywords[currKeywordIndex],
      createdAt: DateTime.now(),
    );

    final List<ElementHandle> elms = await page.$$(
      // '.section-scrollbox div[jsaction*="mouseover:pane"]',
      'div[aria-label*="Results"] div[jsaction*="mouseover:pane"]',
    );
    final ElementHandle elm = elms[currListItemIndex];

    await elm.click();

    await Future.delayed(2.seconds);

    final ElementHandle? titleElm = await page.$OrNull(
      'h1[class*="header-title-title"] span:nth-child(1)',
    );

    if (titleElm != null) {
      final String? title = await titleElm.evaluate(
        'n => n.innerText || null',
      );

      if (title != null && title.isNotEmpty) {
        // print(_title);

        result.title = title;
      }
    }

    final ElementHandle? subTitleElm = await page.$OrNull(
      'h1[class*="header-title-title"] span:nth-child(2)',
    );

    if (subTitleElm != null) {
      final String? subTitle = await subTitleElm.evaluate(
        'n => n.innerText || null',
      );

      if (subTitle != null && subTitle.isNotEmpty) {
        // print(_subTitle);

        result.subTitle = subTitle;
      }
    }

    final ElementHandle? starArrayElm = await page.$OrNull(
      '.section-star-array',
    );

    if (starArrayElm != null) {
      final String? starText = await starArrayElm.evaluate(
        'n => n.parentNode.querySelector("span[aria-hidden=true]").innerText',
      );

      if (starText != null && starText.isNotEmpty) {
        // print(_starText);

        result.star = double.tryParse(starText);
      }
    }

    final ElementHandle? totalReviewElm = await page.$OrNull(
      'button[jsaction="pane.rating.moreReviews"]',
    );

    if (totalReviewElm != null) {
      final String? totalReviewText = await totalReviewElm.evaluate(
        'n => n.innerText || null',
      );

      if (totalReviewText != null && totalReviewText.isNotEmpty) {
        // print(_totalReviewText);

        result.totalReview = int.tryParse(totalReviewText.split(' ').first);
      }
    }

    final ElementHandle? categoryElm = await page.$OrNull(
      'button[jsaction="pane.rating.category"]',
    );

    if (categoryElm != null) {
      final String? categoryName = await categoryElm.evaluate(
        'n => n.innerText || null',
      );

      if (categoryName != null && categoryName.isNotEmpty) {
        // print(_categoryName);

        result.categoryName = categoryName;
      }
    }

    final ElementHandle? attrElm = await page.$OrNull(
      'button[jsaction*="pane.attributes."]',
    );

    if (attrElm != null) {
      final List<ElementHandle> attrElms = await attrElm.$$(
        'div[jsan*="text,"][class*="-text"]',
      );

      if (attrElms.isNotEmpty) {
        final List<String> attrs = <String>[];

        for (ElementHandle attrElm in attrElms) {
          final String? attrText = await attrElm.evaluate(
            'n => n.innerText || null',
          );

          if (attrText != null) {
            attrs.add(attrText);
          }
        }

        if (attrs.isNotEmpty) {
          // print(attrs);

          result.attributes = attrs.map((String s) => s).toList();
        }
      }
    }

    final ElementHandle? addressElm = await page.$OrNull(
      'button[data-item-id="address"] div[jsan*="gm2-body-2"][class*="text"]',
    );

    if (addressElm != null) {
      final String? addressText = await addressElm.evaluate(
        'n => n.innerText || null',
      );

      if (addressText != null && addressText.isNotEmpty) {
        // print(addressText);

        result.address = addressText;
      }
    }

    final ElementHandle? openHoursElm = await page.$OrNull(
      'div[jsaction*="pane.openhours."] span[class*="hour-text"]',
    );

    if (openHoursElm != null) {
      final String? openHoursText = await openHoursElm.evaluate(
        'n => n.innerText || null',
      );

      if (openHoursText != null && openHoursText.isNotEmpty) {
        // print(openHoursText);

        result.openHours = openHoursText;
      }
    }

    final ElementHandle? authorityElm = await page.$OrNull(
      'button[data-item-id="authority"]',
    );

    if (authorityElm != null) {
      await authorityElm.hover();

      final ElementHandle? copyBtnElm = await page.$OrNull(
        'button[jsaction*="pane.focusTooltip"][jsaction*="keydown:pane"][aria-label*="web"] img[src*="copy"]',
      );

      if (copyBtnElm != null) {
        await copyBtnElm.click();

        await Future.delayed(1.seconds);

        final String? clipboard = await page.evaluate(
          '''async () => {
            try {
              return await navigator.clipboard.readText();
            } catch (e) {
              return null;
            }
          }''',
        );

        if (clipboard != null && clipboard.isNotEmpty) {
          // print(clipboard);

          result.websiteUrl = clipboard;
        }
      }
    }

    final ElementHandle? phoneElm = await page.$OrNull(
      'button[data-item-id*="phone:tel"]',
    );

    if (phoneElm != null) {
      final String? phoneText = await phoneElm.evaluate(
        'n => n.getAttribute("data-item-id")',
      );

      if (phoneText != null &&
          phoneText.isNotEmpty &&
          phoneText.contains('tel:')) {
        // print(phoneText.split('tel:')[1].trim());

        result.phoneNumber = phoneText.split('tel:')[1].trim();
      }
    }

    final ElementHandle? heroImageElm = await page.$OrNull(
      'button[jsaction="pane.heroHeaderImage.click"] > img',
    );

    if (heroImageElm != null) {
      final String? imageUrl = await heroImageElm.evaluate(
        'n => n.getAttribute("src")',
      );

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // print(imageUrl);

        result.imageUrl = imageUrl;
      }
    }

    if (result.title != null && result.address != null) {
      result.key = md5
          .convert(utf8.encode('${result.title!}+${result.address}'))
          .toString();

      final ResultSet res = appController.db.select(
        '''SELECT `id`
        FROM `results`
        WHERE `key` = "${result.key}"
        LIMIT 1''',
      );

      if (res.rows.isEmpty) {
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
          result.key,
          result.label,
          result.keyword,
          result.title,
          result.subTitle,
          result.star,
          result.totalReview,
          result.categoryName,
          (result.attributes ?? []).join(','),
          result.address,
          result.openHours,
          result.websiteUrl,
          result.phoneNumber,
          result.imageUrl,
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
          WHERE `key` = "${result.key}"''',
        ).execute([
          result.label,
          result.keyword,
          result.title,
          result.subTitle,
          result.star,
          result.totalReview,
          result.categoryName,
          (result.attributes ?? <String>[]).join(','),
          result.address,
          result.openHours,
          result.websiteUrl,
          result.phoneNumber,
          result.imageUrl,
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

    if (currListItemIndex < elms.length - 1) {
      currListItemIndex++;

      return _loop(page);
    } else {
      final ElementHandle? nextElm = await page.$OrNull(
        'button[jsaction="pane.paginationSection.nextPage"]',
      );

      final bool hasNextPage = nextElm != null
          ? await nextElm.evaluate('n => !n.hasAttribute("disabled")')
          : false;

      if (hasNextPage) {
        logs.clear();

        log('Đang chuyển trang để thu thập danh sách tiếp theo.');

        await nextElm.click();

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
