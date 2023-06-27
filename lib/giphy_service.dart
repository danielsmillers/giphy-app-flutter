import 'dart:convert';
import 'package:http/http.dart' as http;

class GiphyService {
  // API key retrieved from Giphy developers page
  static const String _apiKey = '9mYpnk8TEaagXoeVfLiuOxuujdfvDy2q';

  static Future<List> searchGifs(String query,
      {required int limit, required int offset}) async {
    // Using a HTTP GET request to recieve data(GIFs) from Giphy
    final response = await http.get(
      Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=$_apiKey&q=$query&limit=$limit&offset=$offset'),
    );

    // Checking that the API call was successful by using the responses statuss code
    if (response.statusCode == 200) {
      // Parsing the query body to return a Json object
      final jsonMap = json.decode(response.body);
      // Extracting the image URLs of the GIFs from the JSON response and returning them as a list
      final List<dynamic> data = jsonMap['data'];
      return data.map((gif) => gif['images']['fixed_height']['url']).toList();
    } else {
      // Error handler
      throw Exception('Failed to load GIFs');
    }
  }
}
