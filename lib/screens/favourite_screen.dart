import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../providers/favourite_provider.dart';
import 'meal_detail_screen.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouritesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Favourites',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Expanded(
            child: favsAsync.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_outline,
                            size: 80, color: AppTheme.textGrey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'No favourites yet',
                          style: TextStyle(
                              fontSize: 18, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: meals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final meal = meals[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MealDetailScreen(meal: meal)),
                      ),
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.cardLight),
                        ),
                        child: Row(
                          children: [
                            // Left part with actual picture or icon
                            Container(
                              width: 110,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEBE6), // Light peach
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(24)),
                              ),
                              child: meal.thumbnail != null && meal.thumbnail!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(24)),
                                      child: CachedNetworkImage(
                                        imageUrl: meal.thumbnail!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorWidget: (context, url, error) => Center(
                                          child: Icon(
                                            _getCategoryIcon(meal.category ?? ''),
                                            color: AppTheme.primary,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        _getCategoryIcon(meal.category ?? ''),
                                        color: AppTheme.primary,
                                        size: 32,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 15),
                            // Text info
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.textDark),
                                  ),
                                  if (meal.category != null)
                                    Text(
                                      meal.category!,
                                      style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  if (meal.area != null)
                                    Text(
                                      meal.area!,
                                      style: const TextStyle(
                                          color: AppTheme.textGrey,
                                          fontSize: 14),
                                    ),
                                ],
                              ),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppTheme.primary, size: 28),
                              onPressed: () {
                                ref
                                    .read(favouritesProvider.notifier)
                                    .toggleFavourite(meal);
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'beef':
        return Icons.kebab_dining;
      case 'seafood':
        return Icons.set_meal;
      case 'veggie':
      case 'vegetarian':
      case 'vegan':
        return Icons.grass;
      case 'dessert':
        return Icons.cookie;
      case 'pasta':
        return Icons.local_pizza;
      case 'chicken':
        return Icons.restaurant;
      case 'side':
        return Icons.soup_kitchen;
      default:
        return Icons.restaurant_menu;
    }
  }
}
