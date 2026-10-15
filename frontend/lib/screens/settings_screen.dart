import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../providers/flight_provider.dart';

/// Settings screen — currently only exposes currency selection.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ── Currency ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
            child: Text(
              'CURRENCY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          RadioGroup<Currency>(
            groupValue: provider.currency,
            onChanged: (c) => provider.setCurrency(c!),
            child: Column(
              children: Currency.values
                  .map(
                    (c) => RadioListTile<Currency>(
                      value: c,
                      title: Text('${c.code}  ${c.symbol}'),
                      subtitle: Text('Rate: ${c.rateFromUSD} × USD'),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 32),

          // ── Widget control ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              'WIDGET',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh widget now'),
            subtitle: const Text('Push latest data to your home screen'),
            onTap: () async {
              await provider.refreshWidget();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Widget updated ✓'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const Divider(height: 32),

          // ── About ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              'ABOUT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Flutter Flight Widget'),
            subtitle: Text('v1.0.0 — prototype'),
          ),
          const ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Exchange rates'),
            subtitle: Text('Fixed mock rates — not live data'),
          ),
        ],
      ),
    );
  }
}
