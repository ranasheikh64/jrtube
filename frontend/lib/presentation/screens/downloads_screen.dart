import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../controllers/download_controller.dart';
import '../../widgets/custom_text.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DownloadController controller = Get.find<DownloadController>();
    // Refresh tasks when screen opens
    controller.loadTasks();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const CustomText(text: 'Downloads', fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[900],
      ),
      body: Obx(() {
        final tasks = controller.downloadTasks;
        if (tasks.isEmpty) {
          return const Center(child: CustomText(text: 'No downloads yet.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: task.filename ?? 'Unknown File', fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: task.progress / 100,
                              backgroundColor: Colors.grey[700],
                              color: task.status == DownloadTaskStatus.complete ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomText(text: '${task.progress}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: _getStatusText(task.status),
                            color: _getStatusColor(task.status),
                          ),
                          _buildActionButtons(task, controller),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getStatusText(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.running) return 'Downloading...';
    if (status == DownloadTaskStatus.complete) return 'Completed';
    if (status == DownloadTaskStatus.failed) return 'Failed';
    if (status == DownloadTaskStatus.canceled) return 'Canceled';
    if (status == DownloadTaskStatus.paused) return 'Paused';
    return 'Pending';
  }

  Color _getStatusColor(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.running) return Colors.blue;
    if (status == DownloadTaskStatus.complete) return Colors.green;
    if (status == DownloadTaskStatus.failed) return Colors.red;
    return Colors.grey;
  }

  Widget _buildActionButtons(DownloadTask task, DownloadController controller) {
    if (task.status == DownloadTaskStatus.running) {
      return IconButton(
        icon: const Icon(Icons.pause, color: Colors.orange),
        onPressed: () => FlutterDownloader.pause(taskId: task.taskId),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.green),
        onPressed: () => FlutterDownloader.resume(taskId: task.taskId),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return IconButton(
        icon: const Icon(Icons.folder_open, color: Colors.blue),
        onPressed: () => FlutterDownloader.open(taskId: task.taskId),
      );
    }
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true),
    );
  }
}
