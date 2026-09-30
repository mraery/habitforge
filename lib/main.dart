import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/habit_service.dart';
import 'screens/today_screen.dart';
import 'screens/heatmap_screen.dart';
import 'screens/badges_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await HabitService().init();
  runApp(const HabitForgeApp());
}

class HabitForgeApp extends StatelessWidget {
  const HabitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitForge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
          secondary: Color(0xFFEAB308),
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HabitForgeShell(),
    );
  }
}

class HabitForgeShell extends StatefulWidget {
  const HabitForgeShell({super.key});

  @override
  State<HabitForgeShell> createState() => _HabitForgeShellState();
}

class _HabitForgeShellState extends State<HabitForgeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TodayScreen(),
    HeatmapScreen(),
    BadgesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🔥 HabitForge', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF22C55E), width: 1),
              ),
              child: const Text('Zinciri Kırma', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0B1120),
          indicatorColor: const Color(0xFF22C55E).withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.white54, fontSize: 11);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.check_circle, color: Color(0xFF22C55E)),
              label: 'Bugün',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.grid_view, color: Color(0xFF22C55E)),
              label: 'Isı Haritası',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.emoji_events, color: Colors.amber),
              label: 'Başarılar',
            ),
          ],
        ),
      ),
    );
  }
}
