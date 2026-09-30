import 'dart:convert';

class Habit {
  final String id;
  final String title;
  final String icon;
  final String category;
  int currentStreak;
  int bestStreak;
  final Set<String> completedDates; // YYYY-MM-DD

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    this.currentStreak = 0,
    this.bestStreak = 0,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? {};

  bool isCompletedOn(String dateStr) => completedDates.contains(dateStr);

  bool get isCompletedToday {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return isCompletedOn(todayStr);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'category': category,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'completedDates': completedDates.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        icon: json['icon'] ?? '⚡',
        category: json['category'] ?? 'Genel',
        currentStreak: json['currentStreak'] ?? 0,
        bestStreak: json['bestStreak'] ?? 0,
        completedDates: json['completedDates'] != null
            ? Set<String>.from(json['completedDates'])
            : {},
      );

  static String serializeList(List<Habit> list) =>
      jsonEncode(list.map((h) => h.toJson()).toList());

  static List<Habit> deserializeList(String str) {
    try {
      final decoded = jsonDecode(str) as List;
      return decoded.map((h) => Habit.fromJson(h)).toList();
    } catch (_) {
      return [];
    }
  }
}
