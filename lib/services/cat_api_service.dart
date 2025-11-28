import '../models/cat_image.dart';
import '../models/breed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CatApiService {
  static const _baseUrl = 'https://thecatapi.com/v1';
  static String? _apiKey;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _apiKey = dotenv.get('CAT_API_KEY');
  }

  Future<CatImage> getRandomCatImage() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/images/search'),
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
        throw Exception('Failed to load cat image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future <List<Breed>> getBreeds() async {
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
        throw Exception('CatImage');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}