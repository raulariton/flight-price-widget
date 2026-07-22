// Widget test for Flutter Flight Widget app.
// Tests that the home screen loads successfully.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_flight_widget/main.dart';
import 'package:flutter_flight_widget/providers/flight_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FlightProvider(),
        child: const FlightTrackerApp(),
      ),
    );
    // The app should render (loading spinner initially).
    expect(find.byType(FlightTrackerApp), findsOneWidget);
  });
}
