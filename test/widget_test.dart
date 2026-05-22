import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:respondi/app/app.dart';
import 'package:respondi/core/database/app_database.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await AppDatabase.initialize();
  });

  testWidgets('App launches landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const RespondiApp());
    await tester.pumpAndSettle();

    expect(find.text('RESPONDI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
