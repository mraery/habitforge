import 'package:flutter/material.dart';
import '../services/habit_service.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  final List<Map<String, dynamic>> _badges = const [
    {
      'title': 'İlk Kıvılcım',
      'days': 1,
      'icon': '🌱',
      'desc': 'İlk alışkanlık gününü başarıyla tamamladın. Yolculuk başladı!',
      'color': Color(0xFF10B981),
    },
    {
      'title': '3 Günlük Ateş',
      'days': 3,
      'icon': '🔥',
      'desc': '3 gün üst üste zinciri kırmadın. Momentum oluşuyor.',
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Haftalık Fatih',
      'days': 7,
      'icon': '⚔️',
      'desc': 'Tam 7 gün kesintisiz disiplin. Bir haftayı devirdin!',
      'color': Color(0xFF38BDF8),
    },
    {
      'title': '21 Gün Alışkanlık Kuralı',
      'days': 21,
      'icon': '🧠',
      'desc': 'Psikolojik eşik aşıldı! Bu eylem artık beynine kalıcı olarak kodlandı.',
      'color': Color(0xFFA855F7),
    },
    {
      'title': 'Çelik İrade',
      'days': 50,
      'icon': '🛡️',
      'desc': '50 günlük aralıksız çaba. Erteleme hastalığı sana dokunamaz!',
      'color': Color(0xFFEC4899),
    },
    {
      'title': '100 Günlük Asırlık Efsane',
      'days': 100,
      'icon': '👑',
      'desc': 'Yüz günlük yıkılmaz zincir. Zihinsel dayanıklılığın zirvesindesin!',
      'color': Color(0xFFEAB308),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();

    return ListenableBuilder(
      listenable: habitService,
      builder: (context, _) {
        final habits = habitService.habits;
        final maxStreak = habits.fold(0, (max, h) => h.bestStreak > max ? h.bestStreak : max);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _badges.length,
          itemBuilder: (context, index) {
            final badge = _badges[index];
            final targetDays = badge['days'] as int;
            final isUnlocked = maxStreak >= targetDays;
            final color = badge['color'] as Color;
            final progress = (maxStreak / targetDays).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF151D2A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUnlocked ? color.withValues(alpha: 0.5) : Colors.white10,
                  width: isUnlocked ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isUnlocked ? color.withValues(alpha: 0.2) : Colors.black26,
                      shape: BoxShape.circle,
                      border: Border.all(color: isUnlocked ? color : Colors.white12, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        isUnlocked ? badge['icon'] as String : '🔒',
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                badge['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.white : Colors.white54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUnlocked ? color.withValues(alpha: 0.2) : Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isUnlocked ? 'KAZANILDI' : '$maxStreak / $targetDays Gün',
                                style: TextStyle(
                                  color: isUnlocked ? color : Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge['desc'] as String,
                          style: TextStyle(color: isUnlocked ? Colors.white70 : Colors.white38, fontSize: 12),
                        ),
                        if (!isUnlocked) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
