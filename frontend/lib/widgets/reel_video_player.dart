import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../core/network/network_caller.dart';
import '../presentation/controllers/reels_controller.dart';
import 'custom_text.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnail;
  final bool isActive;

  const ReelVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.thumbnail,
    required this.isActive,
  }) : super(key: key);

  @override
  _ReelVideoPlayerState createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _resolveAndPlay();
  }

  @override
  void didUpdateWidget(ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _videoPlayerController?.play();
        _isPlaying = true;
      } else {
        _videoPlayerController?.pause();
        _isPlaying = false;
      }
    }
  }

  Future<void> _resolveAndPlay() async {
    try {
      final reelsController = Get.find<ReelsController>();
      
      // Check if proactively preloaded
      if (reelsController.preloadedStreams.containsKey(widget.videoUrl)) {
        final streamUrl = reelsController.preloadedStreams[widget.videoUrl]!;
        await _initializePlayer(streamUrl);
        return;
      }

      final response = await NetworkCaller().get('/videos/resolve', queryParameters: {
        'video_url': widget.videoUrl,
        'force_refresh': false,
      });

      if (response != null && response.statusCode == 200) {
        final streamUrl = response.data['stream_url'];
        // Save to cache just in case
        reelsController.preloadedStreams[widget.videoUrl] = streamUrl;
        await _initializePlayer(streamUrl);
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load video stream';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error resolving video';
        });
      }
    }
  }

  Future<void> _initializePlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController!.initialize();
    
    _videoPlayerController!.setLooping(true);

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      if (widget.isActive) {
        _videoPlayerController!.play();
        _isPlaying = true;
      }
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
    
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _isPlaying = false;
      } else {
        _videoPlayerController!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Thumbnail (Shows while loading)
          if (widget.thumbnail != null && (!_isInitialized || _isLoading))
            Image.network(
              widget.thumbnail!,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            )
          else if (!_isInitialized)
            Container(color: Colors.black),
            
          // Video Player
          if (_isInitialized && _videoPlayerController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
            
          // Error Message
          if (_errorMessage.isNotEmpty)
            Center(child: CustomText(text: _errorMessage, color: Colors.red)),
            
          // Loading Indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
            
          // Play Icon overlay when paused
          if (_isInitialized && !_isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.white54,
              ),
            ),
        ],
      ),
    );
  }
}
