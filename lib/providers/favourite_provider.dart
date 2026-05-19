import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../services/database_service.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<Meal>>(
        FavouritesNotifier.new);

class FavouritesNotifier extends AsyncNotifier<List<Meal>> {
  @override
  Future<List<Meal>> build() async {
    final db = ref.watch(databaseServiceProvider);
    return db.getFavourites();
  }

  Future<void> toggleFavourite(Meal meal) async {
    final db = ref.read(databaseServiceProvider);
    final isFav = await db.isFavourite(meal.id);
    if (isFav) {
      await db.deleteFavourite(meal.id);
    } else {
      await db.insertFavourite(meal);
    }
    ref.invalidateSelf();
  }

  Future<bool> isFavourite(String id) async {
    final db = ref.read(databaseServiceProvider);
    return db.isFavourite(id);
  }
}
