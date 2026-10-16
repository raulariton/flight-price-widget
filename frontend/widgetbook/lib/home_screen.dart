import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:flutter_flight_widget/features/home/screens/home_screen.dart';

@widgetbook.UseCase(name: 'Default', type: HomeScreen)
Widget buildHomeScreenUseCase(BuildContext context) {
  return HomeScreen();
}