import 'package:flutter_test/flutter_test.dart';
import 'package:hello_app/main.dart';

void main() {
  testWidgets('Joy Safe Drive opens successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const JoySafeDriveApp());

    expect(find.text('JOY SAFE DRIVE'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Cảnh báo'), findsOneWidget);
  });
}
