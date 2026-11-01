import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_flutter_application/models/order.dart';
import 'package:admin_flutter_application/theme/akea_theme.dart';
import 'package:admin_flutter_application/widgets/akea_ui.dart';

void main() {
  test('akeaMoney formats rand totals', () {
    expect(akeaMoney(0), 'R 0');
    expect(akeaMoney(12500), 'R 12,500');
    expect(akeaMoney(12.5), 'R 12.50');
  });

  test('Order hoursLeft uses the 24h created_at window', () {
    final order = Order(
      id: '1',
      customerId: 'c1',
      status: 'request_sent',
      eventType: 'Wedding',
      eventDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    );
    expect(order.hoursLeft, inInclusiveRange(20, 21));
    expect(order.displayName, 'Client');
    expect(order.guests, 0);
  });

  testWidgets('AkeaButton renders a full-width primary action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AkeaButton(label: 'Log in', expand: true, onPressed: null),
        ),
      ),
    );
    expect(find.text('Log in'), findsOneWidget);
    final box = tester.getSize(find.byType(AkeaButton));
    expect(box.height, 48);
  });
}
