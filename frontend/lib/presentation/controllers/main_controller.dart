import 'package:get/get.dart';

class MainController extends GetxController {
  var currentTabIndex = 0.obs;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
