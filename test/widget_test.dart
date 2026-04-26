import 'package:flutter_test/flutter_test.dart';
import 'package:jantotal/services/storage_service.dart';
import 'package:jantotal/services/app_provider.dart';
import 'package:jantotal/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    final appProvider = AppProvider(storageService);
    await appProvider.init();

    await tester.pumpWidget(MyApp(appProvider: appProvider));
    await tester.pumpAndSettle();

    expect(find.text('対局履歴'), findsOneWidget);
  });
}
