enum PostRating { safe, questionable }

class PostItem {
  const PostItem({
    required this.id,
    required this.previewUrl,
    required this.tags,
    required this.rating,
  });

  final int id;
  final String previewUrl;
  final List<String> tags;
  final PostRating rating;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preview_url': previewUrl,
      'tags': tags,
      'rating': rating.name,
    };
  }

  factory PostItem.fromJson(Map<String, dynamic> json) {
    final ratingName =
        (json['rating'] as String? ?? PostRating.questionable.name)
            .toLowerCase();
    return PostItem(
      id: json['id'] as int,
      previewUrl: json['preview_url'] as String,
      tags: (json['tags'] as List<dynamic>).whereType<String>().toList(),
      rating: ratingName == PostRating.safe.name
          ? PostRating.safe
          : PostRating.questionable,
    );
  }
}
