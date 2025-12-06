import 'package:flutter/material.dart';
import '../models/breed.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CatDetailsScreen extends StatelessWidget {
  final Breed breed;
  final String catImageUrl;
  const CatDetailsScreen({
    super.key,
    required this.breed,
    required this.catImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: catImageUrl,
                width: 350,
                height: 350,
                fit: BoxFit.cover,
                placeholder: (c, u) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (c, e, s) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              breed.description ?? 'Нет описания 😿',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            _infoRow('Страна происхождения', breed.origin ?? 'Неизвестно'),
            _infoRow('Характер', breed.temperament ?? 'Неизвестно'),
            _infoRow('Продолжительность жизни', '${breed.lifeSpan} лет'),

            const SizedBox(height: 20),

            _infoRow('Вес (кг)', breed.weight['metric'] ?? '—'),
            _infoRow('Вес (фунты)', breed.weight['imperial'] ?? '—'),

            const SizedBox(height: 30),

            _rating('Привязанность', breed.affectionLevel),
            _rating('Интеллект', breed.intelligence),
            _rating('Энергичность', breed.energyLevel),
            _rating('Дружелюбность к детям', breed.childFriendly),
            _rating('Дружелюбность к собакам', breed.dogFriendly),
            _rating('Дружелюбность к незнакомцам', breed.strangerFriendly),
            _rating('Коммуникабельность', breed.socialNeeds),
            _rating('Здоровье', breed.healthIssues),
            _rating('Линька', breed.sheddingLevel),
            _rating('Уход', breed.grooming),
            _rating('Говорливость', breed.vocalisation),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget _rating(String title, int? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ($value/5)',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 5,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
