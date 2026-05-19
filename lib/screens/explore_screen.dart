import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/meal.dart';
import '../providers/category_provider.dart';
import '../providers/meal_provider.dart';
import 'meal_detail_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          categoriesAsync.when(
            data: (cats) => SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSelected = selectedCategory == cats[i].name;
                  return FilterChip(
                    label: Text(cats[i].name),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          isSelected ? null : cats[i].name;
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primary.withOpacity(0.15),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textGrey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => const SizedBox(),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Meals Grid
          Expanded(
            child: selectedCategory == null
                ? _buildAllMeals(ref, context)
                : _buildFilteredMeals(ref, context, selectedCategory),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMeals(WidgetRef ref, BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    return mealsAsync.when(
      data: (meals) => _MealGrid(meals: meals),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFilteredMeals(
      WidgetRef ref, BuildContext context, String category) {
    final mealsAsync = ref.watch(mealsByCategoryProvider(category));
    return mealsAsync.when(
      data: (meals) => meals.isEmpty
          ? const Center(child: Text('No meals found'))
          : _MealGrid(meals: meals),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _MealGrid extends StatelessWidget {
  final List<Meal> meals;
  const _MealGrid({required this.meals});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: meals.length,
      itemBuilder: (context, i) {
        final meal = meals[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MealDetailScreen(meal: meal)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: meal.thumbnail != null
                        ? CachedNetworkImage(
                            imageUrl: meal.thumbnail!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.primary.withOpacity(0.1),
                              child: const Icon(Icons.restaurant,
                                  color: AppTheme.primary),
                            ),
                          )
                        : Container(
                            color: AppTheme.primary.withOpacity(0.1),
                            child: const Icon(Icons.restaurant,
                                color: AppTheme.primary),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (meal.area != null)
                        Text(meal.area!,
                            style: const TextStyle(
                                color: AppTheme.textGrey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
