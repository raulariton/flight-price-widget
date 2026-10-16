import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/flight.dart';
import '../../../providers/flight_provider.dart';

/// A card that mimics the home screen widget appearance so the user can see
/// roughly what will appear on their home screen.
class WidgetPreviewCard extends StatelessWidget {
  const WidgetPreviewCard({super.key, required this.flight});
  final Flight flight;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final priceText = provider.currency.format(flight.priceUSD);
    final dateText =
        DateFormat('MMM d, yyyy').format(flight.departureDate);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight_takeoff,
                  color: colorScheme.onPrimary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Widget Preview',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      letterSpacing: 1.1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            flight.route,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.75),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            priceText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.currency.code} · tap widget to open app',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.65),
                ),
          ),
        ],
      ),
    );
  }
}