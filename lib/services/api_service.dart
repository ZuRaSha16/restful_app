import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/object_model.dart';

class ApiService {
  static const String _base = 'https://api.restful-api.dev';
  static const String _apiKey = '5fdb4bad-85ee-4c85-9d52-a403d4d05722';

  Uri _url(String path) => Uri.parse('$_base$path');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'x-api-key': _apiKey,
  };

  Future<List<ObjectModel>> getAll() async {
    final res = await http.get(_url('/objects'), headers: _headers);
    _check(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ObjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _check(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg;
      try {
        msg =
            (jsonDecode(res.body) as Map)['error'] ??
            (jsonDecode(res.body) as Map)['message'] ??
            res.body;
      } catch (_) {
        msg = res.body;
      }
      throw Exception(msg);
    }
  }
}
