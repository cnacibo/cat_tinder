import 'package:flutter/material.dart';
import '../services/cat_api_service.dart';
import '../models/cat_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatApiService _catApiService = CatApiService();
  CatImage? _currentCat;
  int _likesCount = 0; 
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRandomCat();
  }

  Future<void> _loadRandomCat() async {
    try {
      final catImage = await _catApiService.getRandomCatImage();
      setState(() => _currentCat = catImage);
    } catch (e) {
      setState(() => _error = e.toString());
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadRandomCat();
            }, 
            child: const Text('Попробовать загрузить снова'),
          ),
        ],
      ),
    );
  }
}