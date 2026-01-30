import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xeemo_sales/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: XeemoSalesApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed
    expect(find.text('Xeemo Sales'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
