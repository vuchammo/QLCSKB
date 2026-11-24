import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qlcskb/main.dart';
import 'package:qlcskb/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test - verifies initial widget build', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const QlCskbApp(),
      ),
    );

    // Initial state shows loading or main screen
    expect(find.byType(QlCskbApp), findsOneWidget);
  });
}
