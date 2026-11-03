import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
testWidgets('Shiksha app launches successfully', (WidgetTester tester) async {
await tester.pumpWidget(const ShikshaApp());


expect(find.byType(ShikshaApp), findsOneWidget);


});
}
