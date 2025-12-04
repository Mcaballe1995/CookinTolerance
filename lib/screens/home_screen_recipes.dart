import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/appstyles.dart';
import '/screens/first_page.dart';
import '/screens/details_page.dart';
import 'library_page.dart';
import '/models/favorites_manager.dart';
import '/models/recipes.dart';


//Api
const String baseUrl = "https://www.themealdb.com/api/json/v1/1";

class RecipesApp extends StatefulWidget {
  final int initialTab;
  const RecipesApp({super.key,  required this.initialTab});

  @override
  State<RecipesApp> createState() => _RecipesAppState();
}

class _RecipesAppState extends State<RecipesApp> {
  List<dynamic> recipes = [];
  final TextEditingController controller = TextEditingController();
  bool loading = false;
  int _selectedIndex = 0;

  final Map<String, List<String>> intoleranceEndpoints = {

    "Fructose free": [
      // FRUITES AMB FRUCTOSA ALTA
      "apple", "apples", "pear", "pears", "mango", "mangos", "cherry", "cherries", "watermelon", "grape", "grapes", "fig", "figs",
      "date", "dates", "raisin", "raisins",
      // SUCS I DERIVATS
      "fruit juice", "apple juice", "pear juice", "grape juice",
      // EDULCORANTS I SUCRES FRUCTOSATS
      "honey", "agave", "high fructose corn syrup", "hfcs", "fructose", "fructose syrup", "glucose-fructose syrup",
      // VERDURES PROBLEMÀTIQUES EN INTOLERÀNCIA A LA FRUCTOSA
      "artichoke", "asparagus", "sugar snap peas",
      // DOLÇOS QUE NORMALMENT CONTENEN FRUCTOSA
      "jam", "jelly", "marmalade", "sweets", "candy", "chocolate syrup",
      // ALTRES PRODUCTES TIPICAMENT AMB FRUCTOSA
      "soft drink", "soda", "ketchup", "barbecue sauce", "bbq sauce"
    ],

    "Lactose free": [
      "milk","whole milk","skim milk","cream","double cream","heavy cream",
      "butter","ghee","cheese","mozzarella","parmesan","cheddar","yogurt",
      "greek yogurt","milk powder","condensed milk","evaporated milk",
      "cream cheese","ice cream","custard","whey","casein"
    ],

    "Nuts": [
      "peanut","peanuts","peanut butter","almond","almonds","almond flour",
      "walnut","walnuts","pecan","pecans","hazelnut","hazelnuts","pistachio",
      "pistachios","cashew","cashews","nut","nuts","nutmeg (false positive but ok)",
      "macadamia","brazil nut","chestnut"
    ],

    //VEGETARIÀ (sense carn però permet ous/lactis)
    "Vegetarian": [
      // carn
      "chicken","beef","pork","turkey","duck","lamb","goat","veal",
      "bacon","sausage","ham","prosciutto","salami","pepperoni","chorizo",
      // peix + marisc
      "fish","salmon","tuna","cod","hake","trout","anchovy","sardine",
      "seafood","shrimp","prawn","crab","lobster","clam","mussel","oyster","squid",
    ],

    "Vegan": [
      // TOT el de vegetarià +
      "chicken","beef","pork","turkey","duck","lamb","goat","veal",
      "bacon","sausage","ham","prosciutto","salami","pepperoni","chorizo",
      "fish","salmon","tuna","cod","hake","trout","anchovy","sardine",
      "seafood","shrimp","prawn","crab","lobster","clam","mussel","oyster","squid",

      // làctics
      "milk","butter","cheese","cream","yogurt","ice cream","condensed milk",
      "evaporated milk","cream cheese","whey","casein",

      // ous
      "egg","eggs","egg yolk","egg white","mayonnaise",

      // derivats animals
      "honey","gelatin","lard","anchovy paste"
    ],
  };


  Set<String> selectedIntolerances = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    if(_selectedIndex == 0){
      getRandomRecipes();
    }else
    loadManyRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppStyles.drawerHeaderBg),
              child: Center(
                child: Text("Settings", style: AppStyles.drawerHeaderText),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Back to Start"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FirstPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("My library"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LibraryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows_rounded),
              title: const Text("Randomizer"),
              onTap: () {
                getRandomRecipes();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("CookinTolerance", style: AppStyles.appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.horizontalPadding,
              vertical: AppStyles.verticalPadding,
            ),
            child: TextField(
              controller: controller,
              decoration: AppStyles.searchInputDecoration(
                hintText: "Search for a recipe...",
              ),
              onSubmitted: (_) => getRecipesBySearch(),
              onChanged: (value){
                if(value.trim().isEmpty){
                  loadManyRecipes();
                }
              }
            ),
          ),

          // Chips intolerància
          SizedBox(
            height: AppStyles.chipHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.horizontalPadding),
              children: intoleranceEndpoints.keys.map((label) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppStyles.chipSpacing),
                  child: ChoiceChip(
                    label: Text(label, style: AppStyles.chipLabel),
                    selected: selectedIntolerances.contains(label),
                    backgroundColor: AppStyles.chipUnselectedColor,
                    selectedColor: AppStyles.chipSelectedColor,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedIntolerances.add(label);
                        } else {
                          selectedIntolerances.remove(label);
                        }
                      });
                      if (selectedIntolerances.isEmpty){
                        loadManyRecipes();
                      }else{
                        _filterRecipes();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        AppStyles.buildSnackBar("Filter by $label..."),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          //Grid receptes
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : recipes.isEmpty
                ? const Center(child: Text("Recipes not found."))
                : GridView.builder(
              padding: const EdgeInsets.all(AppStyles.gridSpacing),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppStyles.gridSpacing,
                crossAxisSpacing: AppStyles.gridSpacing,
                childAspectRatio: AppStyles.childAspectRatio,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final r = recipes[index];
                return
                  GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsPage(
                          imageUrl: r["strMealThumb"],
                          mealName: r["strMeal"],
                          preparation: r["strInstructions"],
                          ingredients: _extractIngredients(r),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: AppStyles.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppStyles.cardBorderRadius),
                              ),
                              child: Image.network(
                                r["strMealThumb"],
                                height: AppStyles.cardImageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                r["strMeal"],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.recipeTitle,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: FutureBuilder<bool>(
                            future: FavoritesManager.isFavorite(int.parse(r["idMeal"])),
                            builder: (context, snapshot) {
                              final isFav = snapshot.data ?? false;
                              return GestureDetector(
                                onTap: () async {
                                  if (isFav) {
                                    await FavoritesManager.removeFavorite(int.parse(r["idMeal"]));
                                  } else {
                                    await FavoritesManager.addFavorite(
                                      Recipe.fromMealDbJson(r),
                                    );
                                  }
                                  setState(() {}); //Recarrega la UI per canviar el cor, de buit a ple
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },

            ),
          ),
        ],
      ),

      //Navbar
      bottomNavigationBar: AppStyles.buildBottomNavBar(
        context: context,
        currentIndex: _selectedIndex,
        onRandomPressed: (){
          getRandomRecipes();
        }
      ),

    );
  }

  //Barra de cerca
  Future<void> getRecipesBySearch() async {
    final q = controller.text.trim();
    if (q.isEmpty) return;

    setState(() => loading = true);

    final url = Uri.parse("$baseUrl/search.php?s=$q");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      recipes = json["meals"] ?? [];
      _filterRecipes(onlyFilter: true);
    }

    setState(() => loading = false);
  }

  //Random
  Future<void> getRandomRecipes() async {
    setState(() {
      loading = true;
      selectedIntolerances.clear();
    });

    List<dynamic> finalList = [];
    int randomRecipes = 100;

    for (int i = 0; i < randomRecipes; i++) {
      final res = await http.get(Uri.parse("$baseUrl/random.php"));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        finalList.add(json["meals"][0]);
      }
    }

    recipes = finalList;
    setState(() => loading = false);
  }

  //Filtre per ingredients
  void _filterRecipes({bool onlyFilter = false}) {
    if (selectedIntolerances.isEmpty) return;

    List<dynamic> filtered = [];
    int maxIngredients = 100;

    for (var meal in recipes) {
      bool excluir = false;

      //Ingredients a minúscules
      List<String> ingredients = [];
      for (int i = 1; i <= maxIngredients; i++) {
        String? ing = meal["strIngredient$i"];
        if (ing != null && ing.isNotEmpty) {
          ingredients.add(ing.toLowerCase());
        }
      }

      //Mirar xips
      for (var chip in selectedIntolerances) {
        for (var bad in intoleranceEndpoints[chip]!) {
          bad = bad.toLowerCase();

          //Comprovar ingredient que contingui la paraula prohibida
          if (ingredients.any((i) =>
              i.contains(bad)
          )) {
            excluir = true;
          }
        }
      }

      if (!excluir) filtered.add(meal);
    }

    setState(() => recipes = filtered);
  }


  //Afegir moltes receptes al inici
  Future<void> loadManyRecipes() async {
    setState(() {
      loading = true;
      selectedIntolerances.clear();
    });

    final keywords = [
      "chicken", "fish", "rice", "pasta", "salad", "soup", "dessert"
    ];

    List<dynamic> allMeals = [];

    for (var word in keywords) {
      final url = Uri.parse("$baseUrl/search.php?s=$word");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        if (json["meals"] != null) {
          allMeals.addAll(json["meals"]);
        }
      }
    }

    // Evitar duplicats
    final ids = <String>{};
    final uniqueMeals = <dynamic>[];

    for (var meal in allMeals) {
      if (!ids.contains(meal["idMeal"])) {
        ids.add(meal["idMeal"]);
        uniqueMeals.add(meal);
      }
    }

    setState(() {
      recipes = uniqueMeals;
      loading = false;
    });
  }
  List<String> _extractIngredients(Map<String, dynamic> json) {
    List<String> ingredients = [];
    int ingredientsExtracted = 100;

    for (int i = 1; i <= ingredientsExtracted; i++) {
      final ing = json["strIngredient$i"];
      final measure = json["strMeasure$i"];

      if (ing != null && ing.toString().trim().isNotEmpty) {
        ingredients.add("${measure ?? ''} ${ing ?? ''}".trim());
      }
    }
    return ingredients.where((i) => i.isNotEmpty).toList();
  }



}
