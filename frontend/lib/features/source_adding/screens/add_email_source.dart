import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flight_widget/providers/source_email_provider.dart';
import 'package:provider/provider.dart';

class AddEmailSourceScreen extends StatelessWidget {
  const AddEmailSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SourceEmailProvider>();

    if (provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final emailAddress = provider.emailAddress;
    if (provider.error || emailAddress == null) {
      print('$emailAddress, ${provider.error}');
      return Scaffold(
        appBar: AppBar(title: const Text('Add source')),
        body: const Center(
          child: Text(
            'Could not load your forwarding address. Please try again.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add source'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  child: Column(
                    children: [
                      Row(
                        spacing: 12,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          Text('YOUR EMAIL FORWARDING ADDRESS'),
                        ],
                      ),
                      Text(
                        'Forward your Google Flights price alert emails to this address. The app will then monitor this address to extract route details, flight numbers, and price movements.',
                      ),
                      SizedBox(height: 16),
                      EmailCopyField(emailAddress: emailAddress),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailCopyField extends StatelessWidget {
  const EmailCopyField({super.key, required this.emailAddress});
  final String emailAddress;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: emailAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.alternate_email, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              emailAddress,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A2133),
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
