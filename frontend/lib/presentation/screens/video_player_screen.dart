import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import '../controllers/download_controller.dart';
import '../../core/network/network_caller.dart';
import '../../widgets/custom_text.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? thumbnail;

  const VideoPlayerScreen({Key? key, required this.videoUrl, required this.title, this.thumbnail}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _resolveAndPlay();
  }

  Future<void> _resolveAndPlay() async {
    final response = await NetworkCaller().get('/videos/resolve', queryParameters: {
      'video_url': widget.videoUrl,
      'force_refresh': false,
    });

    if (response != null && response.statusCode == 200) {
      final streamUrl = response.data['stream_url'];
      _initializePlayer(streamUrl);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load video stream';
      });
    }
  }

  Future<void> _initializePlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DownloadController downloadController = Get.put(DownloadController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: CustomText(text: widget.title, maxLines: 1),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? Stack(
                    children: [
                      if (widget.thumbnail != null)
                        Center(
                          child: Image.network(
                            widget.thumbnail!,
                            fit: BoxFit.contain,
                            color: Colors.black.withOpacity(0.5),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                      const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ],
                  )
                : _errorMessage.isNotEmpty
                    ? CustomText(text: _errorMessage, color: Colors.red)
                    : Chewie(controller: _chewieController!),
          ),
          
          // Download Button with progress in bottom right corner
          Positioned(
            bottom: 20,
            right: 20,
            child: Obx(() {
              if (downloadController.fetchingUrl.value == widget.videoUrl) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                );
              } else {
                final progress = downloadController.getProgressForUrl(widget.videoUrl);
                if (progress != -1) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.downloading, color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '$progress%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white, size: 30),
                  onPressed: () {
                    downloadController.fetchFormatsAndShowOptions(widget.videoUrl);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
