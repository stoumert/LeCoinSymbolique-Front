
class AnnonceImage {
  final int id;
  final String url;
  final String imageType;

  AnnonceImage({
    required this.id,
    required this.url,
    required this.imageType,
  });

  factory AnnonceImage.fromJson(Map<String, dynamic> json) {
    return AnnonceImage(
      id: json['id'],
      url: json['url'],
      imageType: json['imageType'],
    );
  }
}