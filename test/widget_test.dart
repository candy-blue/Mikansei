import 'package:flutter_test/flutter_test.dart';
import 'package:mikansei/main.dart';

void main() {
  testWidgets('App shows main screen', (tester) async {
    await tester.pumpWidget(const MikanseiApp());
    await tester.pump();

    expect(find.text('Mikansei Flutter'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
