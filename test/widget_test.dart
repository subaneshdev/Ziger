import 'package:flutter_test/flutter_test.dart';
import 'package:ziggers/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZiggersApp());

    // Verify that splash screen is shown
    expect(find.text('Ziggers'), findsOneWidget);
    expect(find.text('Instant Work. Instant Pay.'), findsOneWidget);

    // Allow timer to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
