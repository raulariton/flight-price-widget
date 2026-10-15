import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/flight.dart';
import '../providers/flight_provider.dart';
import '../screens/settings_screen.dart';

/// Main screen: list of trackable flights with selection and widget controls.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Tracker'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Selected widget preview banner ──────────────────────────────────
          if (provider.selectedFlight != null)
            _WidgetPreviewCard(flight: provider.selectedFlight!),

          // ── Section header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SELECT A FLIGHT TO TRACK',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // ── Flight list ──────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              itemCount: provider.flights.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, i) {
                final flight = provider.flights[i];
                final isSelected =
                    provider.selectedFlight?.id == flight.id;
                return _FlightTile(
                  flight: flight,
                  isSelected: isSelected,
                  currency: provider.currency,
                  onTap: () => provider.selectFlight(flight),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flight list tile ──────────────────────────────────────────────────────────

class _FlightTile extends StatelessWidget {
  const _FlightTile({
    required this.flight,
    required this.isSelected,
    required this.currency,
    required this.onTap,
  });

  final Flight flight;
  final bool isSelected;
  final dynamic currency; // Currency enum
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateStr =
        DateFormat('EEE, MMM d yyyy').format(flight.departureDate);

    return ListTile(
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.35),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        child: Text(
          flight.origin,
          style: textTheme.labelSmall?.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      title: Text(
        flight.route,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(flight.airline, style: textTheme.bodySmall),
          Text(dateStr,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currency.format(flight.priceUSD),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            currency.code,
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Widget preview card ───────────────────────────────────────────────────────

/// A card that mimics the home screen widget appearance so the user can see
/// roughly what will appear on their home screen.
class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard({required this.flight});
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
