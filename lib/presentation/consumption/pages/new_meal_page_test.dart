// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NewMealPageTest extends StatefulWidget {
//   const NewMealPageTest({super.key});

//   @override
//   State<NewMealPageTest> createState() => _NewMealPageTestState();
// }

// class _NewMealPageTestState extends State<NewMealPageTest> {
//   File? _image;
//   String? _detectedFood;
//   bool _loading = false;

//   // REPLACE WITH YOUR GOOGLE CLOUD VISION API KEY
//   final String apiKey = "AIzaSyBQOvp8jtA1PdaUwklJFbs61SMlusqnxYs";

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _detectedFood = null;
//       });
//       _analyzeImage(_image!);
//     }
//   }

//   Future<void> _analyzeImage(File image) async {
//     setState(() => _loading = true);

//     List<int> imageBytes = await image.readAsBytes();
//     String base64Image = base64Encode(imageBytes);

//     final url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";
//     final requestBody = jsonEncode({
//       "requests": [
//         {
//           "image": {"content": base64Image},
//           "features": [
//             {"type": "LABEL_DETECTION", "maxResults": 5}
//           ]
//         }
//       ]
//     });

//     print("🔵 Sending request to Google Vision API...");

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {"Content-Type": "application/json"},
//       body: requestBody,
//     );

//     print("🟢 Response received! Status Code: ${response.statusCode}");

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("🔍 API Response Data: $data");

//       if (data['responses'] == null ||
//           data['responses'].isEmpty ||
//           data['responses'][0]['labelAnnotations'] == null) {
//         print("⚠️ No labels found in the response!");
//         setState(() {
//           _detectedFood = "No food detected!";
//           _loading = false;
//         });
//         return;
//       }

//       List labels = data['responses'][0]['labelAnnotations'];

//       String detectedItem = labels.isNotEmpty ? labels[0]['description'] : "Unknown";
//       print("🍏 Detected Food: $detectedItem");

//       setState(() {
//         _detectedFood = detectedItem;
//         _loading = false;
//       });

//       _fetchCalories(detectedItem);
//     } else {
//       print("❌ Error Response: ${response.body}");
//       setState(() {
//         _detectedFood = "Error in detection";
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _fetchCalories(String foodName) async {
//     print("🔍 Searching Firestore for: $foodName");

//     try {
//       var snapshot = await FirebaseFirestore.instance
//           .collection("food_nutrition")
//           .doc(foodName.toLowerCase())
//           .get();

//       if (snapshot.exists) {
//         var data = snapshot.data();
//         print("✅ Firestore Data: $data");

//         setState(() {
//           _detectedFood = "$foodName - ${data?['calories']} kcal";
//         });
//       } else {
//         print("⚠️ Food not found in Firestore.");
//         setState(() {
//           _detectedFood = "$foodName - Calories not found";
//         });
//       }
//     } catch (e) {
//       print("❌ Firestore Error: $e");
//       setState(() {
//         _detectedFood = "$foodName - Error fetching calories";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Food Identification")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image == null
//                 ? const Text("No image selected")
//                 : Image.file(_image!, height: 200),
//             const SizedBox(height: 20),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : Text(
//                     _detectedFood ?? "Click an image to identify food",
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: const Text("Capture Food Image"),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: const Text("Upload from Gallery"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';

class NewMealPageTest extends StatefulWidget {
  const NewMealPageTest({super.key});

  @override
  State<NewMealPageTest> createState() => _NewMealPageTestState();
}

class _NewMealPageTestState extends State<NewMealPageTest> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealTitleController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _addedItems = [];
  Map<String, int> _quantities = {};

  @override
  void dispose() {
    _searchController.dispose();
    _mealTitleController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('food')
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThan: query + '\uf8ff')
          .get();

      setState(() {
        _searchResults =
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        for (var food in _searchResults) {
          _quantities.putIfAbsent(food['name'], () => 1);
        }
      });
    } catch (e) {
      print("[ERROR] Failed to search food: $e");
    }
  }

  void _updateQuantity(String foodName, int change) {
    setState(() {
      int currentQuantity = _quantities[foodName] ?? 1;
      int newQuantity = currentQuantity + change;
      if (newQuantity >= 1) {
        _quantities[foodName] = newQuantity;
      }
    });
  }

  void _addFood(Map<String, dynamic> foodItem) {
    String foodName = foodItem['name'];
    int quantity = _quantities[foodName] ?? 1;

    Map<String, dynamic> addedFood = {
      "name": foodName,
      "calories": (foodItem['calories'] ?? 0) * quantity,
      "protein": (foodItem['protein'] ?? 0) * quantity,
      "carbs": (foodItem['carbs'] ?? 0) * quantity,
      "fat": (foodItem['fat'] ?? 0) * quantity,
      "quantity": quantity
    };

    setState(() => _addedItems.add(addedFood));
  }

   void _removeFood(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }
  
  void _finalizeMeal() {
    if (_addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No items added!")),
      );
      return;
    }

    try {
      var consumptionProvider =
          Provider.of<ConsumptionProvider>(context, listen: false);

      double totalCalories = 0, totalFats = 0, totalCarbs = 0, totalProteins = 0;
      double totalAmount = 0;
      List<String> foodNames = [];

      for (var item in _addedItems) {
        totalCalories += item['calories'];
        totalFats += item['fat'];
        totalCarbs += item['carbs'];
        totalProteins += item['protein'];
        totalAmount += item['quantity'];
        foodNames.add(item['name']);
      }

      String mealTitle = _mealTitleController.text.isNotEmpty
          ? _mealTitleController.text
          : foodNames.join(", ");

      consumptionProvider.addNewMeal(
        title: mealTitle,
        amount: totalAmount,
        calories: totalCalories,
        fats: totalFats,
        carbs: totalCarbs,
        proteins: totalProteins,
        dateTime: DateTime.now(),
      );

      setState(() => _addedItems.clear());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal added successfully!")),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print("[ERROR] Failed to add meal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkGrey, // Dark background
      appBar: AppBar(
        title: const Text(
          'Add Meal',
          style: TextStyle(color: Colors.white), // Title color white
        ),
        backgroundColor: ColorManager.darkGrey,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for food...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchFood,
            ),
            const SizedBox(height: 10),

            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var foodItem = _searchResults[index];
                    String foodName = foodItem['name'];
                    int quantity = _quantities[foodName] ?? 1;

                    return Card(
                      color: Colors.grey[900],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(foodItem['name'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Calories: ${foodItem['calories']}",
                            style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white),
                              onPressed: () => _updateQuantity(foodName, -1),
                            ),
                            Text(quantity.toString(),
                                style: const TextStyle(color: Colors.white)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => _updateQuantity(foodName, 1),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.limeGreen,),
                              onPressed: () => _addFood(foodItem),
                              child: const Text("Add"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_addedItems.isNotEmpty) const Divider(color: Colors.white),

            if (_addedItems.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _addedItems.length,
                  itemBuilder: (context, index) {
                    var foodItem = _addedItems[index];
                    return Card(
                      color: Colors.grey[850],
                      elevation: 5,
                      child: ListTile(
                        title: Text(foodItem['name'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "Calories: ${foodItem['calories']}, Protein: ${foodItem['protein']}g, Carbs: ${foodItem['carbs']}g, Fat: ${foodItem['fat']}g, Quantity: ${foodItem['quantity']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFood(index),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_addedItems.isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.limeGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12)),
                onPressed: _finalizeMeal,
                child: const Text("Add Meal"),
              ),
          ],
        ),
      ),
    );
  }
}
