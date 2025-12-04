import 'package:flutter/material.dart';
import '/screens/home_screen_recipes.dart';
import 'package:projecte_receptes/screens/library_page.dart';

class AppStyles {
  //Colors principals
  static const Color primaryColor = Colors.deepOrange;
  static const Color backgroundColor = Colors.orangeAccent;
  static const Color greyBackground = Color(0xFFE0E0E0);
  static const Color greyText = Colors.grey;
  static const Color drawerHeaderBg = Colors.orange;

  //AppBar
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 26,
  );

  //Barra menu hamburguesa
  static const TextStyle drawerHeaderText = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  //TextField de cerca
  static InputDecoration searchInputDecoration({String hintText = ""}) =>
      InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: greyBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      );

  //Chips
  static const double chipHeight = 45;
  static const TextStyle chipLabel = TextStyle(color: Colors.black);
  static const Color chipSelectedColor = primaryColor;
  static const Color chipUnselectedColor = greyBackground;
  static const double chipSpacing = 8;

  // Cards de receptes
  static const double cardBorderRadius = 16;
  static const double cardElevation = 2;
  static const double cardImageHeight = 180;
  static const TextStyle recipeTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  //Navbar
  static const Color navSelected = primaryColor;
  static const Color navUnselected = greyText;

  // Padding i spacing generals
  static const double horizontalPadding = 16;
  static const double verticalPadding = 10;
  static const double gridSpacing = 10;
  static const double childAspectRatio = 0.8;

  //SnackBars
  static SnackBar buildSnackBar(String text) => SnackBar(
    content: Text(text),
  );

  // Navbar reutilitzable
  static BottomNavigationBar buildBottomNavBar({
    required BuildContext context,
    required int currentIndex,
    Function()? onRandomPressed,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: navSelected,
      unselectedItemColor: navUnselected,
      onTap: (index) {
        if (index == 0) {
          if (onRandomPressed != null) {
            onRandomPressed(); //executa random a la mateixa pàgina
          }
          return;
        }

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RecipesApp(initialTab: 1)),
          );
        }

        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LibraryPage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows_rounded),
          label: "Randomizer",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "My Library",
        ),
      ],
    );
  }

}





