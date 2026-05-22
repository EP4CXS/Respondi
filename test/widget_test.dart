import 'package:flutter_test/flutter_test.dart';

import 'package:respondi/app/app.dart';

void main() {
  testWidgets('App launches landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const RespondiApp());
    await tester.pumpAndSettle();

    expect(find.text('RESPONDI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
