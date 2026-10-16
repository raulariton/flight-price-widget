import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../models/currency.dart';
import '../../providers/flight_provider.dart';

/// Settings screen — currently only exposes currency selection.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Fetched once per screen instance (not on every rebuild) and read from
  // pubspec.yaml's `version:` field via the native build metadata Flutter
  // generates at build time (Info.plist on iOS, build.gradle on Android).
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Currency Selection
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
          // Radio selection list
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
          
          const Divider(height: 32), // const here to force flutter to 
          // not re-build the divider everytime the screen refreshes

          // Refresh widget
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
                    content: Text('Widget updated.'),
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
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final info = snapshot.data;
              final versionText = info == null
                  ? 'Loading version…'
                  : 'v${info.version} (build ${info.buildNumber})';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Flutter Flight Widget'),
                subtitle: Text(versionText),
              );
            },
          ),
          // TODO: Remove or have something like "Sourced from X API"
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
