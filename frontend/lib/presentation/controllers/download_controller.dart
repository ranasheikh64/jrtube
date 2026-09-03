import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'package:frontend/core/network/network_caller.dart';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class DownloadController extends GetxController {
  var downloadingUrl = ''.obs;
  var fetchingUrl = ''.obs;
  var downloadProgress = 0.obs;
  var taskId = ''.obs;

  final ReceivePort _port = ReceivePort();

  @override
  void onInit() {
    super.onInit();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      if (taskId.value == id) {
        downloadProgress.value = progress;
        DownloadTaskStatus currentStatus = DownloadTaskStatus.fromInt(status);
        if (currentStatus == DownloadTaskStatus.complete || currentStatus == DownloadTaskStatus.failed || currentStatus == DownloadTaskStatus.canceled) {
          downloadingUrl.value = '';
        }
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.onClose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isGranted) return true;
      
      var videoStatus = await Permission.videos.request();
      if (videoStatus.isGranted) return true;

      // On Android 13+, DownloadManager can write to public Downloads directory without explicit storage permission
      return true;
    }
    return true;
  }

  Future<void> fetchFormatsAndShowOptions(String url) async {
    try {
      debugPrint('[DownloadController] Fetching formats for: $url');
      fetchingUrl.value = url;
      
      final response = await NetworkCaller().get('/videos/formats?video_url=$url');
      if (fetchingUrl.value == url) fetchingUrl.value = '';

      if (response != null && response.data != null) {
        final List formats = response.data['formats'] ?? [];
        debugPrint('[DownloadController] Received ${formats.length} formats.');
        if (formats.isEmpty) {
          Get.snackbar('Error', 'No downloadable formats found');
          return;
        }
        
        _showDownloadOptionsBottomSheet(formats);
      } else {
        debugPrint('[DownloadController] Failed to fetch formats (null response)');
        Get.snackbar('Error', 'Failed to fetch formats');
      }
    } catch (e) {
      if (fetchingUrl.value == url) fetchingUrl.value = '';
      debugPrint('[DownloadController] Error fetching formats: $e');
      Get.snackbar('Error', 'An error occurred');
    }
  }

  void _showDownloadOptionsBottomSheet(List formats) {
    Get.bottomSheet(
      Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Resolution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: formats.length,
                itemBuilder: (context, index) {
                  final format = formats[index];
                  final sizeMb = (format['filesize'] / (1024 * 1024)).toStringAsFixed(1);
                  return ListTile(
                    title: Text('${format['resolution']} - ${format['ext']}'),
                    subtitle: Text(sizeMb != "0.0" ? '$sizeMb MB' : 'Unknown size'),
                    trailing: const Icon(Icons.download),
                    onTap: () {
                      Get.back();
                      startDownload(format['url'], 'Video_${DateTime.now().millisecondsSinceEpoch}.${format['ext']}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> startDownload(String url, String filename) async {
    bool hasPermission = await _checkPermission();
    if (!hasPermission) {
      Get.snackbar('Permission Denied', 'Storage permission is required to download videos.');
      return;
    }

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      downloadingUrl.value = url;
      downloadProgress.value = 0;
      debugPrint('[DownloadController] Starting background download for $url');
      
      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory!.path,
        fileName: filename,
        showNotification: true,
        openFileFromNotification: true,
      );
      
      if (id != null) {
        taskId.value = id;
        Get.snackbar('Downloading', 'Download started in background');
      } else {
        downloadingUrl.value = '';
      }
    } catch (e) {
      downloadingUrl.value = '';
      Get.snackbar('Error', 'Failed to start download: $e');
    }
  }
}
