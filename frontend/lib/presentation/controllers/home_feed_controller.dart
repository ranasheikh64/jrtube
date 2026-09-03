import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/network/network_caller.dart';
import '../../data/models/video_summary.dart';

class HomeFeedController extends GetxController {
  var videos = <VideoSummary>[].obs;
  var isLoading = true.obs;
  var isPaginating = false.obs;
  
  var currentPlatform = 'YouTube'.obs;
  var searchQuery = ''.obs;
  var currentPage = 1;
  final int limit = 10;
  
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _fetchFeed(isRefresh: true);

    // Listener for infinite scroll
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isPaginating.value && !isLoading.value) {
          _fetchFeed(isRefresh: false);
        }
      }
    });
  }

  Future<void> _fetchFeed({required bool isRefresh}) async {
    if (isRefresh) {
      currentPage = 1;
      isLoading.value = true;
    } else {
      currentPage++;
      isPaginating.value = true;
    }

    final response = await NetworkCaller().get('/feed', queryParameters: {
      'platform': currentPlatform.value.toLowerCase(),
      'query': searchQuery.value,
      'page': currentPage,
      'limit': limit,
    });

    if (response != null && response.statusCode == 200) {
      final List items = response.data['items'];
      final newVideos = items.map((json) => VideoSummary.fromJson(json)).toList();
      
      if (isRefresh) {
        videos.value = newVideos;
      } else {
        videos.addAll(newVideos);
      }
    }

    isLoading.value = false;
    isPaginating.value = false;
  }

  void changePlatform(String platform) {
    if (currentPlatform.value != platform) {
      currentPlatform.value = platform;
      searchQuery.value = ''; // Reset search on platform change
      _fetchFeed(isRefresh: true);
    }
  }

  void searchVideos(String query) {
    searchQuery.value = query;
    _fetchFeed(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
