import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import 'home_screen.dart';
import 'reels_screen.dart';
import 'browser_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  final List<Widget> _screens = const [
    HomeScreen(),
    ReelsScreen(),
    BrowserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: _screens,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: (index) {
          controller.changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Browser',
          ),
        ],
      )),
    );
  }
}
