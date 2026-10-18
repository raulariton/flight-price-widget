import 'package:flutter/foundation.dart';
import 'package:flutter_flight_widget/data/email_source_add_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kForwardingEmail = 'forwarding_email_address';

class SourceEmailProvider extends ChangeNotifier {
  SourceEmailProvider({AddEmailSourceAPI? api}): _api = api ?? AddEmailSourceAPI() {
    _loading = true;
    _init();
  }

  /// For widgetbook and for unit tests
  @visibleForTesting
  SourceEmailProvider.preview({
    String? emailAddress,
    bool loading = false,
    bool error = false,
  }): _api = null {
    _emailAddress = emailAddress;
    _loading = loading;
    _error = error;
  }

  final AddEmailSourceAPI? _api;
  // State
  String? _emailAddress;
  bool _loading = false;
  bool _error = false;

  String? get emailAddress => _emailAddress;
  bool get loading => _loading;
  bool get error => _error;

  Future<void> _init() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _emailAddress = sharedPrefs.getString(_kForwardingEmail);

    if (_emailAddress != null) {
      _loading = false;
      notifyListeners();
      return;
    }

    await _fetchAndStore(sharedPrefs);
  }

  Future<void> _fetchAndStore(SharedPreferences sharedPrefs) async {
    final api = _api;
    if (api == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = false;
    notifyListeners();

    try {
      _emailAddress = await api.getForwardingAddress();
      await sharedPrefs.setString(_kForwardingEmail, _emailAddress!);
    } catch (error) {
      print(error);
      _error = true;
    }

    _loading = false;
    notifyListeners();
  }

  }
