import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';

class CourseStorage {
  static const String _key = 'courses_data';

  // Save courses to SharedPreferences
  static Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> coursesJson =
        courses.map((course) => course.toJson()).toList();
    await prefs.setString(_key, jsonEncode(coursesJson));
  }

  // Load courses from SharedPreferences
  static Future<List<Course>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString(_key);

    if (coursesString == null) {
      return [];
    }

    try {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      return coursesJson.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Clear all courses
  static Future<void> clearCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
