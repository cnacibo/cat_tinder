import '../models/cat_image.dart';
import '../models/breed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CatApiService {
  static const _baseUrl = 'https://api.thecatapi.com/v1';
  static String? _apiKey;

  static Future<void> initialize() async {
    _apiKey = const String.fromEnvironment('CAT_API_KEY');
  }

  Future<CatImage> getRandomCatImage() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/images/search?has_breeds=1&limit=1'),
        headers: _apiKey?.isNotEmpty == true ? {'x-api-key': _apiKey!} : {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return CatImage.fromJson(data.first);
        } else {
          throw Exception('No cat images found');
        }
      } else {
        throw Exception(
          'Failed to load cat image: ${response.statusCode}\n'
          'Response: ${response.body}\n'
          'URL: $_baseUrl/images/search?has_breeds=1',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Breed>> getBreeds() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/breeds'),
        headers: _apiKey?.isNotEmpty == true ? {'x-api-key': _apiKey!} : {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((json) => Breed.fromJson(json)).toList();
        } else {
          throw Exception('Empty data');
        }
      } else {
        throw Exception('Failed to load breeds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
