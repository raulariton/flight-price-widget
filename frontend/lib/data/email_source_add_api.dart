import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String get baseBackendUrl =>
    dotenv.env['BASE_BACKEND_URL'] ?? 'http://localhost:5000';

class AddEmailSourceAPI {
  Future<String> getForwardingAddress() async {
    final res = await http.get(Uri.parse('$baseBackendUrl/email'));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to get forwarding email address: ${res.statusCode}',
      );
    }

    return res.body;
  }
}
