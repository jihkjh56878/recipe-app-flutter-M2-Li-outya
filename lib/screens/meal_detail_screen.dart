import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';
import '../providers/favourite_provider.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  void _checkFav() async {
    final fav = await ref.read(favouritesProvider.notifier).isFavourite(widget.meal.id);
    if (mounted) setState(() => _isFav = fav);
  }

  @override
  Widget build(BuildContext context) {
    // If the meal passed doesn't have instructions, it's likely a partial meal from a filter list.
    // We use the mealDetailProvider to fetch the full details from TheMealDB.
    final fullMealAsync = widget.meal.instructions == null || widget.meal.ingredients.isEmpty
        ? ref.watch(mealDetailProvider(widget.meal.id))
        : AsyncValue.data(widget.meal);

    return Scaffold(
      backgroundColor: Colors.white,
      body: fullMealAsync.when(
        data: (meal) {
          if (meal == null) return const Center(child: Text('Meal not found'));
          return _buildDetailContent(context, meal);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Meal meal) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 80,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      _isFav ? Icons.favorite : Icons.favorite_outline,
                      color: _isFav ? Colors.red : Colors.black,
                    ),
                    onPressed: () async {
                      await ref.read(favouritesProvider.notifier).toggleFavourite(meal);
                      setState(() => _isFav = !_isFav);
                    },
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBE6),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: meal.thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                        child: CachedNetworkImage(
                          imageUrl: meal.thumbnail!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.soup_kitchen,
                            size: 80,
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.soup_kitchen,
                        size: 80,
                        color: AppTheme.primary,
                      ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (meal.category != null)
                      _Tag(label: meal.category!, color: AppTheme.primary),
                    if (meal.area != null)
                      _Tag(label: meal.area!, color: const Color(0xFF2EC4B6)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(meal.ingredients.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${meal.measures[i]} ${meal.ingredients[i]}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A4A4A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                if (meal.instructions != null) ...[
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    meal.instructions!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
