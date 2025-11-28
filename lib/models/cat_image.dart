import 'breed.dart';

class CatImage {
  final String id;
  final String url;
  final int width;
  final int height;
  final List<Breed> breeds;
  final Map<String, dynamic>? favourite;

  CatImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.breeds,
    this.favourite,
  });

  factory CatImage.fromJson(Map<String, dynamic> json) {
    return CatImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      breeds: (json['breeds'] as List<dynamic>? ?? [])
          .map((breedJson) => Breed.fromJson(breedJson))
          .toList(),
      favourite: json['favourite'],
    );
  }
}