import 'package:flutter_test/flutter_test.dart';
import 'package:cikangoutdoor/main.dart';

void main() {
  testWidgets('Cikang Outdoor app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CikangOutdoorApp());
    expect(find.text('Cikang Outdoor'), findsOneWidget);
  });
}
