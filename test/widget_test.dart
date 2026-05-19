import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder/main.dart';

void main() {
  testWidgets('App starts on onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Fixed: Removed 'showOnboarding' because it is no longer used in main.dart
    await tester.pumpWidget(const MyApp());

    // Verify that the first onboarding title is shown.
    expect(find.text('Discover Recipes'), findsOneWidget);
  });
}
