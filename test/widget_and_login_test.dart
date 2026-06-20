import 'package:aetram_ticket_alerts/features/auth/screens/login_screen.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_model.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_status.dart';
import 'package:aetram_ticket_alerts/features/tickets/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login validates required fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });
  testWidgets('ticket card renders professional ticket information', (
    tester,
  ) async {
    final value = TicketModel(
      ticketId: 143,
      subject: 'Unable to sign in',
      description: '<p>Password reset failed</p>',
      createdAt: DateTime(2026, 6, 20),
      subCategoryName: 'Access',
      commentId: 25,
      raisedBy: 'Reeta',
      pickedBy: null,
      fullFilePath: '/a.png',
      status: TicketStatus.open,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketCard(
            ticket: value,
            ticketId: value.ticketId,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Ticket ID: 143'), findsOneWidget);
    expect(find.text('Unable to sign in'), findsOneWidget);
    expect(find.text('Password reset failed'), findsOneWidget);
    expect(find.text('Not assigned'), findsOneWidget);
    expect(find.text('Attachment'), findsOneWidget);
  });
}
