import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'prefs.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImageScreen> {
  final _apiKeyTextController =
      TextEditingController(text: Prefs.getString('google_search_key'));
  final _keywordTextController = TextEditingController(text: 'Deadpool 2');
  final _defaultHeight = 200.0;

  List<ImageResult> _imageResults = [];
  int _startIndex = 1;

  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Image'),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextField(
          controller: _keywordTextController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter Search Keyword',
          ),
          onSubmitted: (String value) => submit(),
        ),
        TextField(
          controller: _apiKeyTextController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter API key',
          ),
          onSubmitted: (String value) => submit(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => submit(),
              child: Text(_startIndex == 1 ? 'Search' : 'More'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageResults = [];
                  _startIndex = 1;
                });
              },
              child: const Text('Clear'),
            )
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: _imageResults.map((imageResult) {
                  return Column(
                    children: [
                      Image.network(
                        imageResult.link,
                        width: imageResult.width.toDouble() *
                            (_defaultHeight / imageResult.height),
                        height: _defaultHeight,
                        fit: BoxFit.cover,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(imageResult.link);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: Text(
                              "${imageResult.width}x${imageResult.height}"))
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ])),
    );
  }

  // Filter list according to the rules below
  // 1. width must be greater than height
  // 2. width must be equals or greater than 800
  List<ImageResult> filterList(List<ImageResult> list) {
    return list.where((element) {
      return element.width > element.height && element.width >= 800;
    }).toList();
  }

  void submit() {
    if (_apiKeyTextController.text.isEmpty) {
      showErrorDialog('Please Input API Key');
    } else if (_keywordTextController.text.isEmpty) {
      showErrorDialog('Please Input Search Keyword');
    } else {
      searchImage(_apiKeyTextController.text, _keywordTextController.text);
    }
  }

  Future<void> searchImage(String apiKey, String query) async {
    try {
      final response = await dio.get(
        'https://www.googleapis.com/customsearch/v1',
        queryParameters: {
          'key': apiKey,
          'cx': '83ab96db02aab40c9',
          'q': query,
          'searchType': 'image',
          'start': _startIndex,
        },
      );

      if (response.statusCode == 200) {
        // Save the apiKey value to persistent storage under the 'google_search_key' key.
        await Prefs.setString('google_search_key', apiKey);

        final data = response.data;
        final imageResults = List<ImageResult>.from(data['items'].map(
                (dynamic e) => ImageResult.fromJson(e as Map<String, dynamic>)))
            .toList();
        final filteredResults = filterList(imageResults);

        // Update state
        setState(() {
          _imageResults += filteredResults;
          _startIndex += 10;
        });
      } else {
        showErrorDialog('Error: ${response.statusCode}');
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog('Error: $e');
      print('Error: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _keywordTextController.dispose();
    _apiKeyTextController.dispose();
    super.dispose();
  }
}

// Class that contains information from Google Image Search result
// This class is used to deserialize JSON result from Google Image Search API response.
class ImageResult {
  final String link;
  final String title;
  final String snippet;
  final int width;
  final int height;

  ImageResult({
    required this.link,
    required this.title,
    required this.snippet,
    required this.width,
    required this.height,
  });

  factory ImageResult.fromJson(Map<String, dynamic> json) {
    return ImageResult(
      link: json['link'],
      title: json['title'],
      snippet: json['snippet'],
      width: json['image']['width'],
      height: json['image']['height'],
    );
  }
}
