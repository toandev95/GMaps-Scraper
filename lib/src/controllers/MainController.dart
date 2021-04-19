import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void tab(int index) {
    tabIndex(index);

    Get.back();
  }

  void zalo() async {
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
}
