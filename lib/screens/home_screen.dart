import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../providers/meal_provider.dart';
import '../providers/category_provider.dart';
import 'meal_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsProvider);
    final randomMealAsync = ref.watch(randomMealProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Foodie!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textGrey),
              ),
              Text(
                'Find your recipe',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.85)),
              ),
            ],
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mealsProvider);
          ref.invalidate(randomMealProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎲 Random Suggestion Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Random suggestion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    randomMealAsync.when(
                      data: (meal) => meal != null ? _RandomMealCard(meal: meal) : const SizedBox(height: 180),
                      loading: () => const _ShimmerBox(height: 180, width: double.infinity),
                      error: (e, _) => const SizedBox(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🍽️ Categories Section (Horizontal Scroll)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              categoriesAsync.when(
                data: (cats) {
                  // Filter and Order categories as requested: Beef, Chicken, Seafood, Pasta, Dessert, Veggie
                  final order = ['Beef', 'Chicken', 'Seafood', 'Pasta', 'Dessert', 'Veggie'];
                  final filtered = <MealCategory>[];
                  for (var name in order) {
                    try {
                      final cat = cats.firstWhere((c) {
                        final cn = c.name.toLowerCase();
                        if (name == 'Veggie') return cn.contains('veg');
                        return cn == name.toLowerCase();
                      });
                      filtered.add(cat);
                    } catch (_) {}
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, i) => _CategoryCard(
                        name: filtered[i].name,
                        thumbnail: filtered[i].thumbnail,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CategoryMealsScreen(category: filtered[i].name)),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(height: 120),
                error: (e, _) => const SizedBox(),
              ),

              const SizedBox(height: 30),

              // 🔥 Popular Meals Section (Horizontal Scroll)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Popular meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              mealsAsync.when(
                data: (meals) => SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: meals.length > 10 ? 10 : meals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, i) => SizedBox(
                      width: 200,
                      child: _PopularMealCard(
                        meal: meals[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meals[i])),
                        ),
                      ),
                    ),
                  ),
                ),
                loading: () => const _ShimmerBox(height: 250, width: double.infinity),
                error: (e, _) => const SizedBox(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _RandomMealCard extends StatelessWidget {
  final Meal meal;
  const _RandomMealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal))),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
          image: meal.thumbnail != null ? DecorationImage(
            image: CachedNetworkImageProvider(meal.thumbnail!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ) : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Text('Random pick', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Text(meal.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (meal.area != null) Text(meal.area!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String? thumbnail;
  final VoidCallback onTap;
  const _CategoryCard({required this.name, this.thumbnail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Standardize naming for display (e.g. 'Vegetarian' -> 'Veggie')
    final displayName = name.toLowerCase().contains('veg') ? 'Veggie' : name;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 85, height: 85,
            decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: thumbnail != null 
                ? CachedNetworkImage(
                    imageUrl: thumbnail!,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(_getIconForCategory(name), color: AppTheme.primary, size: 32),
                  )
                : Icon(_getIconForCategory(name), color: AppTheme.primary, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}

class _PopularMealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  const _PopularMealCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.cardLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: meal.thumbnail != null ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: meal.thumbnail!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(_getIconForCategory(meal.category ?? ''), color: AppTheme.primary, size: 40),
                  ),
                ) : Center(child: Icon(_getIconForCategory(meal.category ?? ''), color: AppTheme.primary, size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (meal.area != null) Text(meal.area!, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  const _ShimmerBox({required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(height: height, width: width, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
    );
  }
}

IconData _getIconForCategory(String name) {
  switch (name.toLowerCase()) {
    case 'beef': return Icons.kebab_dining;
    case 'seafood': return Icons.set_meal;
    case 'veggie': 
    case 'vegetarian':
    case 'vegan': return Icons.grass;
    case 'dessert': return Icons.cookie;
    case 'pasta': return Icons.local_pizza;
    case 'chicken': return Icons.restaurant;
    default: return Icons.restaurant_menu;
  }
}

class CategoryMealsScreen extends ConsumerWidget {
  final String category;
  const CategoryMealsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsByCategoryProvider(category));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('$category Recipes'), backgroundColor: Colors.white, elevation: 0, foregroundColor: AppTheme.textDark),
      body: mealsAsync.when(
        data: (meals) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
          ),
          itemCount: meals.length,
          itemBuilder: (context, i) => _PopularMealCard(
            meal: meals[i],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meals[i]))),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
