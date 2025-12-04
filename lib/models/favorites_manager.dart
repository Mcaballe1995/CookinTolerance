import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipes.dart';

class FavoritesManager {
  static const String _key = "favorite_recipes";

  //Retorna la llista de receptes guardades
  static Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    List<Recipe> favorites = [];

    for (var item in data) {
      if (item.isNotEmpty) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            favorites.add(Recipe.fromMealDbJson(decoded));
          }
        } catch (e) {
          debugPrint("Error decoding favorite item: $e");
        }
      }
    }

    return favorites;
  }

  // Comprova si una recepta ja és favorita
  static Future<bool> isFavorite(int id) async {
    final favs = await getFavorites();
    return favs.any((r) => r.id == id);
  }

  //Afegeix una recepta als favorits
  static Future<void> addFavorite(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = prefs.getStringList(_key) ?? [];

    current.add(jsonEncode({
      'idMeal': recipe.id.toString(),
      'strMeal': recipe.title,
      'strMealThumb': recipe.image,
      'strSource': recipe.sourceUrl,
      'strInstructions': recipe.instructions,
      for (int i = 0; i < recipe.ingredients.length; i++)
        'strIngredient${i + 1}': recipe.ingredients[i],
    }));

    await prefs.setStringList(_key, current);
  }

  //Elimina favorits
  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = prefs.getStringList(_key) ?? [];

    current.removeWhere((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded['idMeal']?.toString() == id.toString();
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(_key, current);
  }
}
