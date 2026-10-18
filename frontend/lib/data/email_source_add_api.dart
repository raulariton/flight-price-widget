import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEmailSourceAPI {
  Future<String> getForwardingAddress() async {
    final res = await http.get(Uri.parse('$BASE_BACKEND_URL/email'));

    if (res.statusCode != 200) {
      throw Exception('Failed to get forwarding email address: ${res.statusCode}');
    }

    return jsonDecode(res.body) as String;
  }
}