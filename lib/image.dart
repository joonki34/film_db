import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImageScreen> {
  final apiKeyTextController = TextEditingController();
  final keywordTextController = TextEditingController(text: 'Deadpool 2');

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
          controller: keywordTextController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter Search Keyword',
          ),
        ),
        TextField(
            controller: apiKeyTextController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter API key',
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                if (apiKeyTextController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const AlertDialog(
                      title: Text('Error'),
                      content: Text('Please Input API Key'),
                    ),
                  );
                } else if (keywordTextController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const AlertDialog(
                      title: Text('Error'),
                      content: Text('Please Input Search Keyword'),
                    ),
                  );
                } else {
                  _searchImage(
                      apiKeyTextController.text, keywordTextController.text);
                }
              },
              child: const Text('Search'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageResults = [];
                  _startIndex = 1;
                });
              },
              child: const Text('Clear'),)
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
                            (300 / imageResult.height),
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(imageResult.link);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: Text("Link ${imageResult.width}x${imageResult.height}"))
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

  Future<void> _searchImage(String apiKey, String query) async {
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
        final data = response.data;
        final imageResults = List<ImageResult>.from(data['items'].map(
                (dynamic e) => ImageResult.fromJson(e as Map<String, dynamic>)))
            .toList();

        // Update state
        setState(() {
          _imageResults += imageResults;
          _startIndex += 10;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    keywordTextController.dispose();
    apiKeyTextController.dispose();
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
