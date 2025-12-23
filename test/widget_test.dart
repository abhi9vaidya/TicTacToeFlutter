// Basic widget test for Tic Tac Toe app

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that the home screen title is displayed
    expect(find.text('TIC TAC TOE'), findsOneWidget);
  });
}
