import 'package:flutter_test/flutter_test.dart';

import 'package:clubwear_app/main.dart';

void main() {
  testWidgets('Splash tampil lalu pindah ke halaman login', (tester) async {
    await tester.pumpWidget(const ClubwearApp());
    expect(find.text('CLUBWEAR'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsOneWidget);
  });
}
