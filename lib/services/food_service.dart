import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodService {
  final String appId = '9b6fd567';
  final String appKey = '0354b40e9df9c5fbdfc2ae8159fcb963';

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final url = Uri.parse(
        'https://trackapi.nutritionix.com/v2/search/instant?query=$query');

    final response = await http.get(url, headers: {
      'x-app-id': appId,
      'x-app-key': appKey,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List commonFoods = data['common'];

      return commonFoods.map<Map<String, dynamic>>((food) {
        return {
          'food_name': food['food_name'],
          'photo': food['photo']['thumb'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  Future<Map<String, dynamic>> getFoodNutrients(String foodName) async {
    final url =
        Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients');

    final response = await http.post(url,
        headers: {
          'x-app-id': appId,
          'x-app-key': appKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({'query': foodName}));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final nutrients = data['foods'][0];

      return {
        'food_name': nutrients['food_name'],
        'serving_weight_grams': nutrients['serving_weight_grams'],
        'calories': nutrients['nf_calories'],
        'carbs': nutrients['nf_total_carbohydrate'],
        'protein': nutrients['nf_protein'],
        'fat': nutrients['nf_total_fat'],
      };
    } else {
      throw Exception('Failed to load nutrients');
    }
  }
} //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
