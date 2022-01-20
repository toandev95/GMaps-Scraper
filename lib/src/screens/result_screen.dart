import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_scraper_app/src/controllers/controllers.dart';
import 'package:google_maps_scraper_app/src/utils/extensions.dart';

class ResultScreen extends GetView<ResultController> {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Kết Quả Đã Lưu Lại'.toUpperCase()),
        actions: <IconButton>[
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              controller.handleExport();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 4.0,
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            width: double.infinity,
            height: 56.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField(
                    hint: const Text('Chọn thư mục'),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.folder_open_rounded,
                      size: 20.0,
                    ),
                    items: controller.labels
                        .map(
                          (String? l) => DropdownMenuItem(
                            value: l,
                            child: Text(l ?? 'Chung'),
                          ),
                        )
                        .toList(),
                    onChanged: (dynamic val) {
                      controller.currLabel.value = val;
                    },
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    hint: const Text('Chọn từ khóa'),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.search_rounded,
                      size: 20.0,
                    ),
                    items: <DropdownMenuItem>[
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...controller.keywords
                          .map(
                            (String l) => DropdownMenuItem(
                              value: l,
                              child: Text(l),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (dynamic val) {
                      controller.currKeyword.value = val;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.results.isEmpty
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: false,
                      child: Text(controller.currLabel.value ?? ''),
                    ),
                    const Icon(
                      Icons.table_view_rounded,
                      color: Colors.grey,
                      size: 90.0,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Không có dữ liệu!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: controller.results.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(controller.results[index].title!),
                    subtitle: Text(controller.results[index].address!),
                    trailing: controller.results[index].createdAt != null
                        ? Text(controller.results[index].createdAt!.format())
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
