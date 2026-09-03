class VideoSummary {
  final String id;
  final String title;
  final String? thumbnail;
  final String url;
  final int? duration;

  VideoSummary({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.url,
    this.duration,
  });

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      thumbnail: json['thumbnail'],
      url: json['url'] ?? '',
      duration: json['duration'],
    );
  }
}
