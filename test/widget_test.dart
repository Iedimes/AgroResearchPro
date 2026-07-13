import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/main.dart';

void main() {
  testWidgets('App shows home modules', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgroResearchProApp()));
    await tester.pumpAndSettle();

    expect(find.text('AgroResearch Pro'), findsWidgets);
    expect(find.text('Gestión de Ensayos'), findsOneWidget);
    expect(find.text('Evaluación de Enfermedades'), findsOneWidget);
  });
}
