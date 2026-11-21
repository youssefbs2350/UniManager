import 'package:flutter_test/flutter_test.dart';
import 'package:unimanager/main.dart';
import 'package:unimanager/widgets/app_logo.dart';

void main() {
  testWidgets('App smoke test - verifies launch and logo display', (WidgetTester tester) async {
    await tester.pumpWidget(const UniManagerApp());
    expect(find.byType(UniManagerApp), findsOneWidget);
    expect(find.byType(UniManagerLogo), findsOneWidget);

    // Écoulement du timer de Splash
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Vérifie qu'on arrive sur l'écran des étudiants
    expect(find.text('Gestion des Étudiants'), findsOneWidget);
  });
}
