import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/cat_api_service.dart';

class BreedsScreen extends StatefulWidget {
  const BreedsScreen({super.key});

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  final CatApiService _catApiService = CatApiService();
  late Future<List<Breed>>? _breedsFuture;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _breedsFuture = _catApiService.getBreeds();
    });
    try {
      await _breedsFuture;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(e.toString());
      });
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
              _loadBreeds();
            },
            child: const Text('Попробовать загрузить снова'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Список пород"), centerTitle: true),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }

          final breeds = snapshot.data ?? [];

          return ListView.separated(
            itemCount: breeds.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final breed = breeds[i];

              return ListTile(
                title: Text(breed.name),
                subtitle: Text(
                  breed.temperament ?? 'Без данных',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(breed.name),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(breed.description ?? "Нет описания 😿"),
                            const SizedBox(height: 16),
                            Text("Страна: ${breed.origin ?? "?"}"),
                            Text("Характер: ${breed.temperament ?? "?"}"),
                            Text("Жизнь: ${breed.lifeSpan ?? "?"} лет"),
                            Text("Интеллект: ${breed.intelligence ?? "?"}/5"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
