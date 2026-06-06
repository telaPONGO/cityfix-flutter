import 'dart:convert';
import 'package:flutter/services.dart';

class DataService {
  static List<Map<String, dynamic>> users = [];
  static List<Map<String, dynamic>> reports = [];
  static Map<String, dynamic>? currentUser;

  static String selectedCity = "Bogotá";

  static Future<void> loadData() async {
    final String response = await rootBundle.loadString('lib/data/data.json');

    final data = json.decode(response);

    users = List<Map<String, dynamic>>.from(data["users"]);
    reports = List<Map<String, dynamic>>.from(data["reports"]);
  }
}
