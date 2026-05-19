import '../core/constants.dart';

class Meal {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnail;
  final String? tags;
  final String? youtubeUrl;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnail,
    this.tags,
    this.youtubeUrl,
    this.ingredients = const [],
    this.measures = const [],
  });

  static String? _fixUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    String cleanUrl = url.trim();
    if (cleanUrl.startsWith('//')) return 'https:$cleanUrl';
    if (!cleanUrl.startsWith('http')) {
      String base = AppConstants.baseUrl;
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      return '$base${cleanUrl.startsWith('/') ? '' : '/'}$cleanUrl';
    }
    return cleanUrl;
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    // 1. Find ID
    String id = (json['idMeal'] ?? json['id'] ?? json['mealId'] ?? '').toString();
    
    // 2. Find Name (Resilient)
    String name = 'Unknown Recipe';
    for (var key in ['strMeal', 'name', 'title', 'label', 'mealName', 'strMealName']) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        name = json[key].toString();
        break;
      }
    }

    // 3. Find Image (Resilient)
    String? thumb;
    for (var key in ['strMealThumb', 'thumbnail', 'image', 'imageUrl', 'img', 'thumb', 'picture', 'photo']) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        thumb = _fixUrl(json[key].toString());
        break;
      }
    }

    // 4. Handle Ingredients
    List<String> ingredients = [];
    List<String> measures = [];
    if (json['ingredients'] is List) {
      ingredients = List<String>.from(json['ingredients']);
      measures = json['measures'] is List ? List<String>.from(json['measures']) : List.filled(ingredients.length, '');
    } else {
      for (int i = 1; i <= 20; i++) {
        final ing = json['strIngredient$i'];
        final msr = json['strMeasure$i'];
        if (ing != null && ing.toString().trim().isNotEmpty) {
          ingredients.add(ing.toString().trim());
          measures.add(msr?.toString().trim() ?? '');
        }
      }
    }

    return Meal(
      id: id,
      name: name,
      category: json['strCategory'] ?? json['category'] ?? json['categoryName'],
      area: json['strArea'] ?? json['area'] ?? json['cuisine'],
      instructions: json['strInstructions'] ?? json['instructions'] ?? json['description'],
      thumbnail: thumb,
      tags: json['strTags'] ?? json['tags'],
      youtubeUrl: json['strYoutube'] ?? json['youtubeUrl'] ?? json['video'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'thumbnail': thumbnail,
      'tags': tags,
      'youtubeUrl': youtubeUrl,
      'ingredients': ingredients.join('||'),
      'measures': measures.join('||'),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'],
      area: map['area'],
      instructions: map['instructions'],
      thumbnail: map['thumbnail'],
      tags: map['tags'],
      youtubeUrl: map['youtubeUrl'],
      ingredients: map['ingredients'] != null ? (map['ingredients'] as String).split('||') : [],
      measures: map['measures'] != null ? (map['measures'] as String).split('||') : [],
    );
  }
}
