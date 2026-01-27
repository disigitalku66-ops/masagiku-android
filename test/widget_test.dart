import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masagiku_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MasagiApp()));

    // Verify that our counter starts at 0.is displayed
    expect(find.text('Masagiku'), findsWidgets);
  });
}
