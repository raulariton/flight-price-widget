import 'package:flutter/material.dart';
import 'package:flutter_flight_widget/providers/flight_provider.dart';
import 'package:flutter_flight_widget/data/sample_flights.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// This file does not exist yet,
// it will be generated in the next step
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // The [directories] variable does not exist yet,
      // it will be generated in the next step
      directories: directories,
      appBuilder: ((context, child) => ChangeNotifierProvider(
        create: (_) => FlightProvider.preview(selected: sampleFlights.first),
        child: child,
      )),
    );
  }
}
