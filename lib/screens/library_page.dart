import 'package:flutter/material.dart';
import '../../models/favorites_manager.dart';
import '../../models/recipes.dart';
import '../../models/appstyles.dart';
import 'details_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Recipe> favs = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    loadFavs();

  }

  Future<void> loadFavs() async {
    final favList = await FavoritesManager.getFavorites();
    setState(() {
      favs = favList;
    });
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final isFav = await FavoritesManager.isFavorite(recipe.id);

    if (isFav) {
      await FavoritesManager.removeFavorite(recipe.id);
    } else {

      final cleanRecipe = Recipe(
        id: recipe.id,
        title: recipe.title,
        image: recipe.image,
        instructions: recipe.instructions.trim().isNotEmpty == true
            ? recipe.instructions
            : "No hi ha instruccions disponibles",
        ingredients: recipe.ingredients
            .where((i) =>  i.trim().isNotEmpty)
            .map((i) => i.trim())
            .toList(),
      );

      await FavoritesManager.addFavorite(cleanRecipe);
    }

    loadFavs();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        elevation: 1,
        title: const Text("My Library", style: AppStyles.appBarTitle),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: favs.isEmpty
          ? const Center(child: Text("No recipes saved yet."))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: favs.length,
        itemBuilder: (context, index) {
          final r = favs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsPage(
                    imageUrl: r.image,
                    mealName: r.title,
                    preparation: r.instructions,
                    ingredients: r.ingredients.map((i) => i).toList(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: AppStyles.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppStyles.cardBorderRadius),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(
                                AppStyles.cardBorderRadius)),
                        child: Image.network(
                          r.image,
                          height: AppStyles.cardImageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppStyles.recipeTitle,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await toggleFavorite(r);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4)
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppStyles.buildBottomNavBar(
        context: context,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
