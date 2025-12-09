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
  List<Breed> _filteredBreeds = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _breedsFuture = _catApiService.getBreeds();
    });
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    
    _breedsFuture?.then((breeds) {
      if (query.isEmpty) {
        setState(() {
          _filteredBreeds = breeds;
          _isSearching = false;
        });
      } else {
        setState(() {
          _filteredBreeds = breeds.where((breed) {
            return breed.name.toLowerCase().contains(query) ||
                (breed.origin?.toLowerCase().contains(query) ?? false) ||
                (breed.temperament?.toLowerCase().contains(query) ?? false);
          }).toList();
          _isSearching = true;
        });
      }
    });
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Loading Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _getUserFriendlyError(error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBreeds,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserFriendlyError(Object error) {
    final errorString = error.toString();
    
    if (errorString.contains('SocketException') || 
        errorString.contains('Network is unreachable')) {
      return 'Check your internet connection!';
    } else if (errorString.contains('TimeoutException')) {
      return 'Timeout Exception. Try again later!';
    } else if (errorString.contains('404')) {
      return 'Breeds data not found';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search breeds...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedCard(Breed breed) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final countryColor = Theme.of(context).colorScheme.secondary;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor, 
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBreedDetails(breed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breed.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (breed.origin != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            breed.origin!,
                            style: TextStyle(
                              fontSize: 14,
                              color: countryColor,
                            ),
                          ),
                        ],
                      ),
                    if (breed.temperament != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        breed.temperament!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRatingChip('❤️', breed.affectionLevel ?? 0, textColor),
                        const SizedBox(width: 8),
                        _buildRatingChip('⚡', breed.energyLevel ?? 0, textColor),
                        const SizedBox(width: 8),
                        _buildRatingChip('🧠', breed.intelligence ?? 0, textColor),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip(String emoji, int rating, Color baseColor) {
    Color getColor(int rating) {
      if (rating >= 4) return Colors.green;
      if (rating >= 3) return Colors.orange;
      return Colors.red;
    }

    final color = getColor(rating);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            '$rating',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBreedDetails(Breed breed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          breed.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                breed.description ?? 'No description available 😿',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
            
              _buildDetailRow('📍 Origin', breed.origin ?? 'Unknown'),
              _buildDetailRow('😸 Temperament', breed.temperament ?? 'Unknown'),
              _buildDetailRow('📅 Life Span', '${breed.lifeSpan} years'),
              
              const SizedBox(height: 16),
              
              Text(
                'Characteristics',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCharacteristic('Affection', breed.affectionLevel),
                  _buildCharacteristic('Energy', breed.energyLevel),
                  _buildCharacteristic('Intelligence', breed.intelligence),
                  _buildCharacteristic('Child Friendly', breed.childFriendly),
                  _buildCharacteristic('Health', breed.healthIssues),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristic(String label, int? value) {
    if (value == null) return const SizedBox.shrink();
    
    Color getColor(int rating) {
      if (rating >= 4) return Colors.green;
      if (rating >= 3) return Colors.orange;
      return Colors.red;
    }
    
    final color = getColor(value);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value/5',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No breeds found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Cat Breeds',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error!);
          }

          final breeds = snapshot.data ?? [];
          final displayBreeds = _isSearching ? _filteredBreeds : breeds;

          return Column(
            children: [
              _buildSearchBar(),
              if (displayBreeds.isEmpty && _isSearching)
                Expanded(child: _buildEmptyState())
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: displayBreeds.length,
                    itemBuilder: (context, index) {
                      return _buildBreedCard(displayBreeds[index]);
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${displayBreeds.length} breeds found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}