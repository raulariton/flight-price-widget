import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_flights.dart';
import '../models/currency.dart';
import '../models/flight.dart';

// SharedPreferences keys
const _kSelectedFlightId = 'selected_flight_id';
const _kSelectedCurrency = 'selected_currency';

// home_widget App Group ID (must match iOS extension App Group)
const _kAppGroupId = 'group.com.example.flutterFlightWidget';

// home_widget keys written to the shared container
const _kwRoute = 'widget_route';
const _kwPrice = 'widget_price';
const _kwDate = 'widget_date';
const _kwUpdated = 'widget_updated';

/// Central state for the app — selected flight and currency.
///
/// Persists selection to [SharedPreferences] and pushes data to the
/// home screen widget via [HomeWidget] whenever either changes.
class FlightProvider extends ChangeNotifier {
  FlightProvider() {
    _init();
  }

  final List<Flight> flights = sampleFlights;

  Flight? _selectedFlight;
  Currency _currency = Currency.usd;
  bool _loading = true;

  Flight? get selectedFlight => _selectedFlight;
  Currency get currency => _currency;
  bool get loading => _loading;

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> _init() async {
    // Tell home_widget which App Group to use (required on iOS).
    await HomeWidget.setAppGroupId(_kAppGroupId);

    final prefs = await SharedPreferences.getInstance();

    final savedCurrency = prefs.getString(_kSelectedCurrency);
    if (savedCurrency != null) {
      _currency = Currency.fromCode(savedCurrency);
    }

    final savedId = prefs.getString(_kSelectedFlightId);
    if (savedId != null) {
      _selectedFlight =
          flights.firstWhere((f) => f.id == savedId, orElse: () => flights[0]);
    }

    _loading = false;
    notifyListeners();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Select a flight, persist to prefs, and update the widget.
  Future<void> selectFlight(Flight flight) async {
    _selectedFlight = flight;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedFlightId, flight.id);
    await _updateWidget();
  }

  /// Change currency, persist, and update the widget.
  Future<void> setCurrency(Currency c) async {
    _currency = c;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedCurrency, c.code);
    await _updateWidget();
  }

  /// Force-refresh the widget with the currently stored values.
  /// Exposed so the UI can offer a manual refresh button.
  Future<void> refreshWidget() async => _updateWidget();

  // ── Widget update ───────────────────────────────────────────────────────────

  /// Pushes the selected flight data to the home screen widget.
  ///
  /// Each key/value pair is written via [HomeWidget.saveWidgetData] and then
  /// [HomeWidget.updateWidget] is called to trigger a visual refresh on both
  /// Android (via AppWidgetProvider) and iOS (via WidgetKit Timeline reload).
  Future<void> _updateWidget() async {
    final flight = _selectedFlight;
    if (flight == null) return;

    final priceFormatted = _currency.format(flight.priceUSD);
    final dateFormatted =
        DateFormat('MMM d, yyyy').format(flight.departureDate);
    final updatedFormatted =
        DateFormat('h:mm a').format(DateTime.now());

    // Write each data field to the shared container.
    await Future.wait([
      HomeWidget.saveWidgetData(_kwRoute, flight.route),
      HomeWidget.saveWidgetData(_kwPrice, priceFormatted),
      HomeWidget.saveWidgetData(_kwDate, dateFormatted),
      HomeWidget.saveWidgetData(_kwUpdated, updatedFormatted),
    ]);

    // Trigger the OS to redraw the widget.
    // - Android: qualifiedAndroidName must match the AppWidgetProvider class.
    // - iOS:     iOSName must match the Widget extension kind.
    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'com.example.flutter_flight_widget.FlightWidgetProvider',
      iOSName: 'FlightWidget',
    );

    if (kDebugMode) {
      debugPrint('[FlightProvider] Widget updated → $priceFormatted');
    }
  }
}
