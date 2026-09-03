import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/network_caller.dart';
import '../../data/models/video_summary.dart';

class ReelsController extends GetxController {
  var videos = <VideoSummary>[].obs;
  var isLoading = false.obs;
  var isPaginating = false.obs;
  
  var currentPlatform = 'YouTube'.obs;
  String currentQuery = '';
  
  int currentPage = 1;
  final int limit = 10;
  
  // Track which page index in the PageView is currently active
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReels(isRefresh: true);
  }

  void changePlatform(String platform) {
    if (currentPlatform.value == platform) return;
    currentPlatform.value = platform;
    fetchReels(isRefresh: true);
  }

  Future<void> fetchReels({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      currentPage = 1;
      videos.clear();
      currentIndex.value = 0;
    } else {
      if (isPaginating.value) return;
      isPaginating.value = true;
      currentPage++;
    }

    try {
      final response = await NetworkCaller().get('/reels', queryParameters: {
        'query': currentQuery,
        'platform': currentPlatform.value.toLowerCase(),
        'page': currentPage,
        'limit': limit,
      });

      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = response.data['items'];
        final newVideos = data.map((json) => VideoSummary.fromJson(json)).toList();
        
        if (isRefresh) {
          videos.assignAll(newVideos);
        } else {
          videos.addAll(newVideos);
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch reels.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  // Cache for resolved stream URLs
  var preloadedStreams = <String, String>{}.obs;
  bool _isPreloading = false;

  void onPageChanged(int index) {
    currentIndex.value = index;
    // Load more when reaching the end
    if (index >= videos.length - 2) {
      fetchReels();
    }
    
    // Proactively preload next 3 reels
    _preloadNextReels(index);
  }

  Future<void> _preloadNextReels(int index) async {
    if (_isPreloading) return;
    _isPreloading = true;

    try {
      for (int i = index + 1; i <= index + 3; i++) {
        if (i < videos.length) {
          final url = videos[i].url;
          if (!preloadedStreams.containsKey(url)) {
            final response = await NetworkCaller().get('/videos/resolve', queryParameters: {
              'video_url': url,
              'force_refresh': false,
            });
            if (response != null && response.statusCode == 200) {
              preloadedStreams[url] = response.data['stream_url'];
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error preloading reels: $e");
    } finally {
      _isPreloading = false;
    }
  }
}
