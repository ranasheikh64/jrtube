import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/reels_controller.dart';
import '../controllers/main_controller.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/reel_video_player.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReelsController controller = Get.put(ReelsController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Vertical PageView
          Obx(() {
            if (controller.isLoading.value && controller.videos.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (controller.videos.isEmpty) {
              return const Center(child: CustomText(text: 'No reels found.', color: Colors.white));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              allowImplicitScrolling: true,
              itemCount: controller.videos.length,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (context, index) {
                final video = controller.videos[index];
                
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Obx(() {
                      final mainController = Get.find<MainController>();
                      final isTabActive = mainController.currentTabIndex.value == 1;
                      final isActive = controller.currentIndex.value == index && isTabActive;
                      
                      return ReelVideoPlayer(
                        videoUrl: video.url,
                        thumbnail: video.thumbnail,
                        isActive: isActive,
                      );
                    }),
                    
                    // Video Info Overlay
                    Positioned(
                      bottom: 20.h,
                      left: 16.w,
                      right: 60.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: video.title,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            maxLines: 2,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Reels • ${video.duration ?? 0}s',
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }),
          
          // Filters at the top
          Positioned(
            top: 50.h, // Safe area top margin approx
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(text: 'Reels', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                Obx(() => PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  color: Colors.grey[900],
                  initialValue: controller.currentPlatform.value,
                  onSelected: (platform) {
                    controller.changePlatform(platform);
                  },
                  itemBuilder: (context) => ['YouTube', 'Facebook', 'TikTok'].map((platform) {
                    return PopupMenuItem<String>(
                      value: platform,
                      child: Row(
                        children: [
                          Icon(
                            controller.currentPlatform.value == platform
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: controller.currentPlatform.value == platform
                                ? Colors.redAccent
                                : Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            text: platform,
                            color: controller.currentPlatform.value == platform
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
