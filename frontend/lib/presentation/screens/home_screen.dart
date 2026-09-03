import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/screens/video_player_screen.dart';
import 'package:get/get.dart';
import '../controllers/home_feed_controller.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_searchfield.dart';

import '../controllers/download_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeFeedController controller = Get.put(HomeFeedController());
    final DownloadController downloadController = Get.put(DownloadController());
    final TextEditingController searchController = TextEditingController();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const CustomText(text: 'Video Viewer', fontSize: 20, fontWeight: FontWeight.bold),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchField(
                        controller: searchController,
                        hintText: 'Search videos...',
                        onSubmitted: (val) => controller.searchVideos(val),
                        onClear: () {
                          searchController.clear();
                          controller.searchVideos('');
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
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
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (controller.videos.isEmpty) {
              return const Center(child: CustomText(text: 'No videos found.'));
            }

            return ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.videos.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.videos.length) {
                  return controller.isPaginating.value 
                      ? Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final video = controller.videos[index];
                return InkWell(
                  onTap: () {
                    Get.to(() => VideoPlayerScreen(
                      videoUrl: video.url, 
                      title: video.title,
                      thumbnail: video.thumbnail,
                    ));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            if (video.thumbnail != null)
                              Image.network(video.thumbnail!, width: double.infinity, height: 200.h, fit: BoxFit.cover)
                            else
                              Container(width: double.infinity, height: 200.h, color: Colors.grey[800]),
                            Positioned(
                              bottom: 8.h,
                              right: 8.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Obx(() {
                                  if (downloadController.isFetchingFormats.value) {
                                    return const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                    );
                                  } else if (downloadController.isDownloading.value) {
                                    return Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.downloading, color: Colors.blue, size: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${downloadController.downloadProgress.value}%',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return IconButton(
                                    icon: const Icon(Icons.download, color: Colors.white),
                                    onPressed: () {
                                      downloadController.fetchFormatsAndShowOptions(video.url);
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.w),
                          child: CustomText(text: video.title, fontSize: 16, fontWeight: FontWeight.bold, maxLines: 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        // Removed global progress bar as progress is shown in the icon
      ],
    );
  }
}
