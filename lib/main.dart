import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/cat_api_service.dart';
import 'screens/breeds_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CatApiService.initialize();
  runApp(const CatTinder());
}

class CatTinder extends StatelessWidget {
  const CatTinder({super.key});

  @override
  Widget build(BuildContext context) {
    final myTheme = ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF283618),    
          onPrimary: Colors.white,
          secondary: const Color(0xFFDDA15E), 
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF283618),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF283618),
          elevation: 2,
          centerTitle: true,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color(0xFF283618).withOpacity(0.3),
          indicatorColor: Color(0xFF283618).withOpacity(0.5),
          surfaceTintColor: Color(0xFF283618), 
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      );

    return MaterialApp(
      title: 'Cat Tinder',
      theme: myTheme,
      home: const MainTabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const BreedsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Cats'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Breeds'),
        ],
      ),
    );
  }
}
