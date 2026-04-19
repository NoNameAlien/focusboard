import 'package:flutter_test/flutter_test.dart';

import 'package:focusboard/app/app.dart';
import 'package:focusboard/app/di/injector.dart';

void main() {
  testWidgets('App checks auth state and opens login page for guest', (
    WidgetTester tester,
  ) async {
    await setupDependency();

    await tester.pumpWidget(const App());

    expect(find.text('FocusBoard'), findsOneWidget);
    expect(find.text('Checking session...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
