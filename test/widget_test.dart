
import 'package:flutter_test/flutter_test.dart';
import 'package:tracktify/main.dart';

void main() {
  testWidgets('Tracktify app dapat dijalankan', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
