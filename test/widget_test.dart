import 'package:flutter_test/flutter_test.dart';
import 'package:habitforge/main.dart';

void main() {
  testWidgets('HabitForgeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitForgeApp());
    expect(find.textContaining('HabitForge'), findsOneWidget);
  });
}
