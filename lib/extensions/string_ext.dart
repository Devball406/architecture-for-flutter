import 'dart:convert';

extension StringExtension on String {
  Map<String, dynamic> toJsonMap() {
    return Map<String, dynamic>.from(json.decode(this));
  }
}
