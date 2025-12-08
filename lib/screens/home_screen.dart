import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cat_api_service.dart';
import '../models/cat_image.dart';
import './cat_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatApiService _catApiService = CatApiService();
  Future<CatImage>? _catFuture;
  int _likesCount = 0;
  String? _currentCatImageUrl;

  @override
  void initState() {
    super.initState();
    _loadRandomCat();
  }

  Future<void> _loadRandomCat() async {
    setState(() {
      _catFuture = _catApiService.getRandomCatImage();
      _currentCatImageUrl = _generateCatUrl();
    });
  }

  void _handleSwipe(bool isRight) {
    if (isRight) {
      setState(() => _likesCount++);
    }
    _loadRandomCat();
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
              'Loading error',
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
              onPressed: _loadRandomCat,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again!'),
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
      return 'The cat is not found 🐱';
    } else if (errorString.contains('500')) {
      return 'Something is wrong with the server!';
    } else if (errorString.contains('No breeds available')) {
      return 'Breed information is not available!';
    }
    
    return 'Something is wrong. Try again!';
  }

  Widget _buildCatCard(CatImage catImage) {
    final cardKey = ValueKey(catImage.id);

    double dragX = 0.0;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setLocalState(() {
              dragX += details.delta.dx;
            });
          },
          onHorizontalDragEnd: (details) {
            if (dragX > 120) {
              _handleSwipe(true);
            } else if (dragX < -120) {
              _handleSwipe(false);
            }
            setLocalState(() {
              dragX = 0;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..translate(dragX),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatDetailsScreen(
                        breed: catImage.breeds.first,
                        catImageUrl: _currentCatImageUrl ?? _generateCatUrl(),
                      ),
                    ),
                  );
                },
                child: Card(
                  key: cardKey,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      _buildCatImage(catImage),
                      _buildBreedNameOverlay(catImage),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatImage(CatImage catImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth * 0.9;
          final double imageSize = maxWidth;
          
          return SizedBox(
            width: imageSize,
            height: imageSize,
            child: CachedNetworkImage(
              imageUrl: _currentCatImageUrl ?? _generateCatUrl(),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black.withOpacity(0.05),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, error, stackTrace) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('Error while loading the image...'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadRandomCat,
                        child: const Text('Try again!'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _generateCatUrl() {
    return 'https://cataas.com/cat?type=square&timestamp=${DateTime.now().millisecondsSinceEpoch}';
  }

  Widget _buildBreedNameOverlay(CatImage catImage) {
    final breedName = catImage.breeds.isNotEmpty
        ? catImage.breeds.first.name
        : 'Неизвестная порода';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.75), Colors.transparent],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          breedName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black45,
                offset: Offset(0, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.close,
          color: Color(0xFFBF0603),
          onTap: () => _handleSwipe(false),
        ),
        _buildActionButton(
          icon: Icons.favorite,
          color: Color(0xFF386641),
          onTap: () => _handleSwipe(true),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, 
          shape: BoxShape.circle,
          border: Border.all(
            color: color, 
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30), 
      ),
    );
  }

  Widget _buildLikesCounter() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.white),
          const SizedBox(width: 4),
          Text('$_likesCount', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildMainContent(CatImage catImage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(child: _buildCatCard(catImage)),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
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
          'Cat Tinder',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, 
          ),
        ),
        centerTitle: true,
        actions: [_buildLikesCounter()],
      ),
      body: FutureBuilder<CatImage>(
        future: _catFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error ?? 'Unknown error');
          }

          if (snapshot.hasData) {
            return _buildMainContent(snapshot.data!);
          }

          return _buildErrorWidget(Exception('No data for this cat!'));
        },
      ),
    );
  }
}
