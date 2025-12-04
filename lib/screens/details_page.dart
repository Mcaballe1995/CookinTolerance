import 'package:flutter/material.dart';
import '../../models/appstyles.dart';
import 'ingredients_page.dart';

class DetailsPage extends StatefulWidget {
  final String imageUrl;
  final String mealName;
  final String preparation;
  final List<String> ingredients;

  const DetailsPage({
    super.key,
    required this.imageUrl,
    required this.mealName,
    required this.preparation,
    required this.ingredients,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Nom de la recepta + botó Ingredients
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.mealName,
                          style: AppStyles.recipeTitle.copyWith(fontSize: 22),
                        ),
                      ),
                      ActionChip(
                        label: const Text(
                          "Ingredients",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IngredientsPage(
                                mealName: widget.mealName,
                                ingredients: widget.ingredients,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Imatge
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 20),

                  //Contenidor semi transparent
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PREPARATION STEPS:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._buildPreparationSteps(widget.preparation),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: AppStyles.buildBottomNavBar(
        context: context,
        currentIndex: 1,
      ),


    );
  }
  List<Widget> _buildPreparationSteps(String text) {

    text = text.replaceAll("\r", "");


    final rawParts = text
        .split(RegExp(r'[.\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final steps = rawParts;

    return List.generate(steps.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}. ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                steps[index],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    });
  }

}


