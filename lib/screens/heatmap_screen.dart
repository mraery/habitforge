import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  String? _selectedHabitId; // null = Tümü

  Color _getColorForIntensity(int count, int maxPossible) {
    if (count == 0) return const Color(0xFF1E293B);
    final ratio = maxPossible > 0 ? (count / maxPossible) : 0.0;
    if (ratio >= 0.75) return const Color(0xFF22C55E); // Neon Bright Green
    if (ratio >= 0.50) return const Color(0xFF16A34A); // Medium Green
    if (ratio >= 0.25) return const Color(0xFF15803D); // Forest Green
    return const Color(0xFF14532D); // Deep Green
  }

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();

    return ListenableBuilder(
      listenable: habitService,
      builder: (context, _) {
        final habits = habitService.habits;
        final selectedHabit = _selectedHabitId != null
            ? habits.firstWhere((h) => h.id == _selectedHabitId, orElse: () => Habit(id: '', title: '', icon: '', category: ''))
            : null;

        // Generate past 20 weeks (140 days) for optimal mobile view with horizontal scroll
        final now = DateTime.now();
        final List<List<DateTime>> weeks = [];
        final int numWeeks = 18;

        // Start from beginning of current week
        DateTime currentDay = now.subtract(Duration(days: now.weekday - 1));
        DateTime startDay = currentDay.subtract(Duration(days: (numWeeks - 1) * 7));

        for (int w = 0; w < numWeeks; w++) {
          final List<DateTime> week = [];
          for (int d = 0; d < 7; d++) {
            week.add(startDay.add(Duration(days: w * 7 + d)));
          }
          weeks.add(week);
        }

        // Calculate statistics
        int totalCheckins = 0;
        final activeDates = <String>{};

        for (final h in (_selectedHabitId == null ? habits : [selectedHabit!])) {
          for (final d in h.completedDates) {
            activeDates.add(d);
            totalCheckins++;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Habit selector dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedHabitId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('🌐 Tüm Alışkanlıkların Ortalaması', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      ),
                      ...habits.map((h) => DropdownMenuItem<String?>(
                            value: h.id,
                            child: Text('${h.icon} ${h.title}'),
                          )),
                    ],
                    onChanged: (val) => setState(() => _selectedHabitId = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // KPI Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Aktif Günler',
                      '${activeDates.length}',
                      'Gün zincir kırılmadı',
                      Icons.calendar_today,
                      Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      'Toplam Tamamlama',
                      '$totalCheckins',
                      'Başarılı tik',
                      Icons.done_all,
                      Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      'En İyi Seri',
                      selectedHabit != null ? '${selectedHabit.bestStreak}' : '${habits.fold(0, (max, h) => h.bestStreak > max ? h.bestStreak : max)}',
                      'Gün aralıksız',
                      Icons.local_fire_department,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Heatmap Grid Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🟩 Alışkanlık Isı Haritası (Son 18 Hafta)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('GitHub Tarzı', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Scrollable Matrix
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Scroll to recent weeks
                      child: Row(
                        children: weeks.map((week) {
                          return Column(
                            children: week.map((date) {
                              final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              final isFuture = date.isAfter(now);

                              int count = 0;
                              int maxPossible = _selectedHabitId == null ? habits.length : 1;

                              if (!isFuture) {
                                if (_selectedHabitId == null) {
                                  count = habitService.getCompletionsForDate(dStr);
                                } else {
                                  count = selectedHabit!.isCompletedOn(dStr) ? 1 : 0;
                                }
                              }

                              final cellColor = isFuture
                                  ? Colors.transparent
                                  : _getColorForIntensity(count, maxPossible);

                              return Tooltip(
                                message: '$dStr: $count tamamlama',
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(3),
                                    border: isFuture ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Az ', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        _buildLegendSquare(const Color(0xFF1E293B)),
                        _buildLegendSquare(const Color(0xFF14532D)),
                        _buildLegendSquare(const Color(0xFF15803D)),
                        _buildLegendSquare(const Color(0xFF16A34A)),
                        _buildLegendSquare(const Color(0xFF22C55E)),
                        const Text(' Çok', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Habit Consistency Breakdown
              const Text('Alışkanlık Devamlılık Oranları', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...habits.map((h) {
                final daysCompleted = h.completedDates.length;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Text(h.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Toplam $daysCompleted gün tamamlandı', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '🔥 ${h.currentStreak} gün',
                          style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(String title, String val, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLegendSquare(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
