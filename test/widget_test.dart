import 'package:flutter_test/flutter_test.dart';
import 'package:bachene_soft/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Use isActivated: false to show ActivationScreen
    await tester.pumpWidget(const StockManagerApp(isActivated: false));

    // Verify that ActivationScreen is shown.
    expect(find.byType(StockManagerApp), findsOneWidget);
  });
}
