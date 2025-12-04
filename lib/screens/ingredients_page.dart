import 'package:flutter/material.dart';
import '../../models/appstyles.dart';

class IngredientsPage extends StatefulWidget {
  final String mealName;
  final List<String> ingredients;

  const IngredientsPage({
    super.key,
    required this.mealName,
    required this.ingredients,
  });

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("CookinTolerance", style: AppStyles.appBarTitle),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Ingredients:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.ingredients.map((ingredient) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                ).toList(),
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: AppStyles.buildBottomNavBar(
        context: context,
        currentIndex: _selectedIndex,
      ),

    );
  }
}
