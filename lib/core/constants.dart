class AppConstants {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // TheMealDB doesn't require the X-DB-NAME header for the free tier.
  static const Map<String, String> headers = {};
}
