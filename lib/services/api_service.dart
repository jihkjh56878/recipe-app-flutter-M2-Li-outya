import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/meal.dart';
import '../models/category.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      // Ensure baseUrl ends with a slash for correct path joining
      baseUrl: AppConstants.baseUrl.endsWith('/') 
          ? AppConstants.baseUrl 
          : '${AppConstants.baseUrl}/',
      headers: AppConstants.headers,
      // TIMEOUT SET TO 1 HOUR (3600000 ms) FOR STABILITY AS REQUESTED
      connectTimeout: const Duration(hours: 1),
      receiveTimeout: const Duration(hours: 1),
      sendTimeout: const Duration(hours: 1),
    ));
    
    // Safety: Only log errors to prevent console overload/crash
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) {
        debugPrint('Network Status: ${e.type} - ${e.message}');
        return handler.next(e);
      },
    ));
  }

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson, String key) {
    if (data == null || data is! Map) return [];
    final list = data[key];
    if (list is List) {
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<Meal>> getMeals() async {
    try {
      final response = await _dio.get('search.php', queryParameters: {'s': ''});
      return _parseList(response.data, Meal.fromJson, 'meals');
    } catch (_) { return []; }
  }

  Future<List<MealCategory>> getCategories() async {
    try {
      final response = await _dio.get('categories.php');
      return _parseList(response.data, MealCategory.fromJson, 'categories');
    } catch (_) { return []; }
  }

  Future<List<String>> getAreas() async {
    try {
      final response = await _dio.get('list.php', queryParameters: {'a': 'list'});
      if (response.data is Map && response.data['meals'] is List) {
        return (response.data['meals'] as List)
            .map((e) => (e['strArea'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) { return []; }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await _dio.get('filter.php', queryParameters: {'c': category});
      return _parseList(response.data, Meal.fromJson, 'meals');
    } catch (_) { return []; }
  }

  Future<List<Meal>> getMealsByArea(String area) async {
    try {
      final response = await _dio.get('filter.php', queryParameters: {'a': area});
      return _parseList(response.data, Meal.fromJson, 'meals');
    } catch (_) { return []; }
  }

  Future<Meal?> getRandomMeal() async {
    try {
      final response = await _dio.get('random.php');
      final meals = _parseList(response.data, Meal.fromJson, 'meals');
      return meals.isNotEmpty ? meals.first : null;
    } catch (_) { return null; }
  }

  Future<Meal?> getMealById(String id) async {
    try {
      final response = await _dio.get('lookup.php', queryParameters: {'i': id});
      final meals = _parseList(response.data, Meal.fromJson, 'meals');
      return meals.isNotEmpty ? meals.first : null;
    } catch (_) { return null; }
  }
}
