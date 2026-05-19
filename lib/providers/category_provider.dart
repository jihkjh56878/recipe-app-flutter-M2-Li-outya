import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'meal_provider.dart';

final categoriesProvider = FutureProvider<List<MealCategory>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
