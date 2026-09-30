import 'package:flutter/material.dart';
import '../services/habit_service.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedIcon = '⚡';
    String selectedCat = 'Sağlık';

    final icons = ['⚡', '📖', '💻', '💧', '🏃‍♂️', '🧘', '🍎', '✍️', '🎯', '💤'];
    final categories = ['Sağlık', 'Kariyer', 'Zihin', 'Fitness', 'Farkındalık', 'Diğer'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Yeni Alışkanlık Başlat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Alışkanlık Başlığı (örn: Her Gün 10 Sayfa Oku)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Simge:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: icons.map((ic) {
                    final isSel = selectedIcon == ic;
                    return InkWell(
                      onTap: () => setModalState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF22C55E).withValues(alpha: 0.3) : Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? const Color(0xFF22C55E) : Colors.white12),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Kategori:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: categories.map((cat) {
                    final isSel = selectedCat == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: const Color(0xFF22C55E),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 11),
                      onSelected: (val) {
                        if (val) setModalState(() => selectedCat = cat);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.black),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                HabitService().addHabit(title, selectedIcon, selectedCat);
                Navigator.pop(ctx);
              },
              child: const Text('Zincire Başla', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();
    final now = DateTime.now();
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final dateTitle = '${now.day} ${months[now.month - 1]} ${days[now.weekday - 1]}';

    return ListenableBuilder(
      listenable: habitService,
      builder: (context, _) {
        final habits = habitService.habits;
        final completed = habitService.completedTodayCount;
        final total = habits.length;
        final rate = habitService.todayCompletionRate;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date & Motivational Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0F2F24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateTitle, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$completed / $total Tamamlandı', style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Zinciri Kırma!',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '"Geleceğini değiştiremezsin; alışkanlıklarını değiştirebilirsin ve alışkanlıkların geleceğini değiştirir."',
                      style: TextStyle(color: Colors.white60, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Add Habit Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddHabitDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Yeni Alışkanlık Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              // Habits List
              const Text('Bugünün Alışkanlıkları', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (habits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                  child: const Center(
                    child: Text('Henüz eklenmiş bir alışkanlık yok.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                )
              else
                ...habits.map((habit) {
                  final isDone = habit.isCompletedToday;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? const Color(0xFF22C55E).withValues(alpha: 0.5) : Colors.white12,
                        width: isDone ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFF22C55E).withValues(alpha: 0.2) : Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title & Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: TextStyle(
                                  color: isDone ? Colors.white70 : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(habit.category, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🔥 ', style: TextStyle(fontSize: 9)),
                                        Text('${habit.currentStreak} Gün Seri', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Checkbox
                        InkWell(
                          onTap: () => habitService.toggleToday(habit.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFF22C55E) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDone ? const Color(0xFF22C55E) : Colors.white38,
                                width: 2,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.black, size: 24)
                                : null,
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
}
