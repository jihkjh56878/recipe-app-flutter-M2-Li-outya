import '../core/constants.dart';

class MealCategory {
  final String id;
  final String name;
  final String? thumbnail;
  final String? description;

  MealCategory({
    required this.id,
    required this.name,
    this.thumbnail,
    this.description,
  });

  static String? _fixUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    String cleanUrl = url.trim();
    // Fix protocol-relative URLs
    if (cleanUrl.startsWith('//')) return 'https:$cleanUrl';
    // Fix relative paths
    if (!cleanUrl.startsWith('http')) {
      String base = AppConstants.baseUrl;
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      // TheMealDB specific image path fix if necessary
      if (base.contains('themealdb.com') && !cleanUrl.contains('images')) {
        return 'https://www.themealdb.com/images/category/$cleanUrl';
      }
      return '$base${cleanUrl.startsWith('/') ? '' : '/'}$cleanUrl';
    }
    return cleanUrl;
  }

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    // 1. Find Name (Resilient search)
    String categoryName = 'Unknown';
    final nameKeys = ['strCategory', 'name', 'title', 'label', 'category', 'categoryName'];
    for (var key in nameKeys) {
      if (json[key] != null && json[key].toString().trim().isNotEmpty) {
        categoryName = json[key].toString().trim();
        break;
      }
    }

    // 2. Find Image (Resilient search)
    String? thumb;
    final imgKeys = ['strCategoryThumb', 'thumbnail', 'image', 'imageUrl', 'img', 'thumb', 'picture', 'photo'];
    for (var key in imgKeys) {
      if (json[key] != null && json[key].toString().trim().isNotEmpty) {
        thumb = _fixUrl(json[key].toString().trim());
        break;
      }
    }

    return MealCategory(
      id: (json['idCategory'] ?? json['id'] ?? json['categoryId'] ?? '').toString(),
      name: categoryName,
      thumbnail: thumb,
      description: json['strCategoryDescription'] ?? json['description'],
    );
  }
}
