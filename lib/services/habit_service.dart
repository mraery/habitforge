import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitService extends ChangeNotifier {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  List<Habit> _habits = [];
  bool _initialized = false;

  List<Habit> get habits => List.unmodifiable(_habits);

  static const String _keyHabits = 'habitforge_habits_v1';

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyHabits);

    if (str != null && str.isNotEmpty) {
      _habits = Habit.deserializeList(str);
    } else {
      _seedDefaultHabits();
      await _saveHabits();
    }

    _recalculateStreaks();
    _initialized = true;
    notifyListeners();
  }

  void _seedDefaultHabits() {
    final now = DateTime.now();
    final pastDates1 = <String>{};
    final pastDates2 = <String>{};
    final pastDates3 = <String>{};
    final pastDates4 = <String>{};

    // Generate some realistic past completions for the last 40 days
    for (int i = 0; i < 40; i++) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (i % 7 != 5) pastDates1.add(dateStr); // ~85% consistency
      if (i < 15 || (i > 18 && i < 35)) pastDates2.add(dateStr); // streak 15
      if (i % 2 == 0) pastDates3.add(dateStr);
      if (i < 8) pastDates4.add(dateStr);
    }

    _habits = [
      Habit(id: 'h_1', title: 'Kitap Oku (20 Sayfa)', icon: '📖', category: 'Zihin', currentStreak: 6, bestStreak: 21, completedDates: pastDates1),
      Habit(id: 'h_2', title: 'Kodlama & Algoritma', icon: '💻', category: 'Kariyer', currentStreak: 15, bestStreak: 15, completedDates: pastDates2),
      Habit(id: 'h_3', title: '2.5 Litre Su İç', icon: '💧', category: 'Sağlık', currentStreak: 3, bestStreak: 14, completedDates: pastDates3),
      Habit(id: 'h_4', title: 'Egzersiz & Yürüyüş', icon: '🏃‍♂️', category: 'Fitness', currentStreak: 8, bestStreak: 12, completedDates: pastDates4),
      Habit(id: 'h_5', title: 'Günün Muhasebesi & Şükür', icon: '🧘', category: 'Farkındalık', currentStreak: 4, bestStreak: 10),
    ];
  }

  void _recalculateStreaks() {
    final now = DateTime.now();
    for (final h in _habits) {
      int streak = 0;
      // Count backwards from today or yesterday
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final hasToday = h.completedDates.contains(todayStr);

      DateTime checkDate = hasToday ? now : now.subtract(const Duration(days: 1));
      while (true) {
        final dStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        if (h.completedDates.contains(dStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      h.currentStreak = streak;
      if (h.currentStreak > h.bestStreak) {
        h.bestStreak = h.currentStreak;
      }
    }
  }

  Future<void> toggleToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => Habit(id: '', title: '', icon: '', category: ''));
    if (habit.id.isEmpty) return;

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (habit.completedDates.contains(todayStr)) {
      habit.completedDates.remove(todayStr);
    } else {
      habit.completedDates.add(todayStr);
    }

    _recalculateStreaks();
    await _saveHabits();
    notifyListeners();
  }

  Future<void> addHabit(String title, String icon, String category) async {
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      icon: icon,
      category: category,
      currentStreak: 0,
      bestStreak: 0,
    );
    _habits.add(newHabit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveHabits();
    notifyListeners();
  }

  int get completedTodayCount => _habits.where((h) => h.isCompletedToday).length;

  double get todayCompletionRate => _habits.isNotEmpty ? (completedTodayCount / _habits.length) : 0.0;

  // Total completions for any specific date
  int getCompletionsForDate(String dateStr) {
    return _habits.where((h) => h.completedDates.contains(dateStr)).length;
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHabits, Habit.serializeList(_habits));
  }
}
