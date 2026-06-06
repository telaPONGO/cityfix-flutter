import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import '../models/user.dart';
import 'storage_service.dart';

class ApiService {
  // Use a custom backend host at build time with
  // flutter build apk --dart-define=CITYFIX_API_HOST=http://192.168.x.x:3001
  static const String _apiHost = String.fromEnvironment(
    'CITYFIX_API_HOST',
    defaultValue: 'https://cityfix-backend-v7tt.onrender.com',
  );

  static String get baseUrl => '$_apiHost/api';

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> _headers({bool auth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> init() async {
    setToken(StorageService.getCurrentUserToken());
  }

  static Future<List<Report>> fetchReports({bool onlyMyReports = false}) async {
    try {
      final endpoint =
          onlyMyReports ? '$baseUrl/reports/my' : '$baseUrl/reports';
      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: _headers(auth: onlyMyReports),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Report.fromJson(item)).toList();
      }
    } catch (_) {
      // Fallback local data handled by AppController.
    }
    return [];
  }

  static Future<User?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: _headers(),
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['user'] != null && body['token'] != null) {
          final token = body['token'].toString();
          setToken(token);
          await StorageService.setCurrentUserToken(token);
          return User.fromJson(Map<String, dynamic>.from(body['user']));
        }
      }
    } catch (_) {
      // Ignore and fallback to local storage.
    }
    return null;
  }

  static Future<bool> register(User user) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: _headers(),
            body: json.encode(user.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['token'] != null) {
          final token = body['token'].toString();
          setToken(token);
          await StorageService.setCurrentUserToken(token);
        }
        return true;
      }
    } catch (_) {
      // Ignore and fallback to local storage.
    }
    return false;
  }

  // Returns a map with success flag and optional message for errors.
  static Future<Map<String, dynamic>> createReport(Report report) async {
    try {
      // Debug: log headers (mask token) to detect missing auth header
      try {
        final headers = _headers(auth: true);
        var auth = headers['Authorization'] ?? 'none';
        if (auth is String && auth.startsWith('Bearer ')) {
          final token = auth.substring(7);
          final masked = token.length > 12
              ? '${token.substring(0, 6)}...${token.substring(token.length - 6)}'
              : '***';
          // ignore: avoid_print
          print('[ApiService.createReport] Authorization: Bearer $masked');
        } else {
          // ignore: avoid_print
          print('[ApiService.createReport] Authorization header: none');
        }
      } catch (_) {}

      final response = await http
          .post(
            Uri.parse('$baseUrl/reports'),
            headers: _headers(auth: true),
            body: json.encode(report.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return {'success': true, 'data': body};
      }

      // Log failed response for debugging
      try {
        // ignore: avoid_print
        print(
            '[ApiService.createReport] status: ${response.statusCode}, body: ${response.body}');
      } catch (_) {}

      String message = 'Error desconocido';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        } else {
          message = response.body.toString();
        }
      } catch (_) {
        message = response.body.toString();
      }

      return {
        'success': false,
        'message': message,
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<Report>> fetchMyReports() async {
    return fetchReports(onlyMyReports: true);
  }

  static Future<Map<String, dynamic>> deleteReport(String id) async {
    try {
      final headers = _headers(auth: true);
      var auth = headers['Authorization'] ?? 'none';
      if (auth is String && auth.startsWith('Bearer ')) {
        final token = auth.substring(7);
        final masked = token.length > 12
            ? '${token.substring(0, 6)}...${token.substring(token.length - 6)}'
            : '***';
        // ignore: avoid_print
        print('[ApiService.deleteReport] Authorization: Bearer $masked');
      } else {
        // ignore: avoid_print
        print('[ApiService.deleteReport] Authorization header: none');
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/reports/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      }

      String message = 'Error desconocido';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        } else {
          message = response.body.toString();
        }
      } catch (_) {
        message = response.body.toString();
      }

      // ignore: avoid_print
      print(
          '[ApiService.deleteReport] status: ${response.statusCode}, body: ${response.body}');
      return {
        'success': false,
        'message': message,
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
