import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void tab(int index) {
    tabIndex.value = index;

    Get.back();
  }

  void zalo() async {
    try {
      final String _zalo = 'https://zalo.me/0849181883';

      if (await canLaunch(_zalo)) {
        await launch(_zalo);
      }

      Get.back();
    } catch (e) {
      Get.back();
      Get.rawSnackbar(
        message: 'Không thể mở liên kết.',
      );
    }
  }
}
