import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMeals();
});

final randomMealProvider = FutureProvider<Meal?>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getRandomMeal();
});

final areasProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getAreas();
});

final mealsByCategoryProvider =
    FutureProvider.family<List<Meal>, String>((ref, category) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMealsByCategory(category);
});

final mealsByAreaProvider =
    FutureProvider.family<List<Meal>, String>((ref, area) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMealsByArea(area);
});

final mealDetailProvider = FutureProvider.family<Meal?, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMealById(id);
});
