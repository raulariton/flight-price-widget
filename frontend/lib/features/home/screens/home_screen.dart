import 'package:flutter/material.dart';
import 'package:flutter_flight_widget/features/source_adding/screens/add_email_source.dart';
import 'package:flutter_flight_widget/providers/source_email_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/flight_provider.dart';
import '../../settings/settings_screen.dart';

/// Main screen: list of trackable flights with selection and widget controls.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Simplify context providing
    final provider = context.watch<FlightProvider>();

    if (provider.loading) {
      // If provider is still loading flights, return screen (scaffold)
      // with spinner
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          Center(
            child: Column(
              children: [
                Column(
                  children: [
                    Text('No flights tracked yet'),
                    Text(
                      'Add your first source to start receiving real-time price drops and widgets',
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => SourceEmailProvider(),
                        child: const AddEmailSourceScreen(),
                      ),
                    ),
                  ),
                  child: const Text('Add your first source'),
                ),
              ],
            ),
          ),
          // // Construct widget preview card with selected flight
          // if (provider.selectedFlight != null)
          //   WidgetPreviewCard(flight: provider.selectedFlight!),

          // // Section Header
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          //   child: Text(
          //     'SELECT A FLIGHT TO TRACK',
          //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
          //           letterSpacing: 1.2,
          //           color: Theme.of(context).colorScheme.primary,
          //         ),
          //   ),
          // ),

          // // Flight list: Expanded gives all
          // // available vertical space in column to the list
          // Expanded(
          //   child: ListView.separated(
          //     itemCount: provider.flights.length,
          //     separatorBuilder: (_, _) =>
          //         const Divider(height: 1, indent: 16, endIndent: 16),
          //     itemBuilder: (context, i) {
          //       final flight = provider.flights[i];
          //       final isSelected =
          //           provider.selectedFlight?.id == flight.id;
          //       return FlightListItem(
          //         flight: flight,
          //         isSelected: isSelected,
          //         currency: provider.currency,
          //         onTap: () => provider.selectFlight(flight),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ── Flight list tile ──────────────────────────────────────────────────────────
