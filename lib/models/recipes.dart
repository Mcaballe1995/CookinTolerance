
class RecipeResponse {
  final List<Recipe> recipes;


  RecipeResponse({required this.recipes});


  factory RecipeResponse.fromMealDbJson(List<dynamic> meals) {
    return RecipeResponse(
      recipes: meals.map((m) => Recipe.fromMealDbJson(m)).toList(),
    );
  }
}


class Recipe {
  final int id;
  final String title;
  final String image;
  final String? sourceUrl;
  final List<String> ingredients;
  final String instructions;


  Recipe({required this.id, required this.title, required this.image, this.sourceUrl, required this.ingredients, required this.instructions});



  factory Recipe.fromMealDbJson(Map<String, dynamic> json) {
    List<String> ingredientsList = [];

    for (int i = 1; i <= 20; i++) {
      final ing = json["strIngredient$i"]?.toString().trim();
      final measure = json["strMeasure$i"]?.toString().trim();

      if (ing != null && ing.isNotEmpty) {
        // Si measure és null o buit, només afegim l’ingredient, d'aquesta forma no apareixen els null
        if (measure != null && measure.isNotEmpty) {
          ingredientsList.add("$measure $ing");
        } else {
          ingredientsList.add(ing);
        }
      }
    }

    return Recipe(
      id: int.tryParse(json['idMeal']?.toString() ?? '') ?? 0,
      title: json['strMeal'] ?? 'Sense títol',
      image: json['strMealThumb'] ??
          'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg',
      sourceUrl: json['strSource'] ?? json['strYoutube'],
      ingredients: ingredientsList,
      instructions: json['strInstructions'] ?? '',
    );
  }

}
