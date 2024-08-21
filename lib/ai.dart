import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'util.dart';
import 'prefs.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _promptTextController = TextEditingController();
  final _apiKeyTextController =
      TextEditingController(text: Prefs.getString('gemini_api_key'));
  final _responseTextController = TextEditingController();

  GenerativeModel? _generativeAI;
  bool _isLoading = false; // Add a loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _promptTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Prompt',
              ),
            ),
            TextField(
              controller: _apiKeyTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter API Key',
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : submit, // Disable button while loading
                    child: const Text('Generate'),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: _responseTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Response',
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submit() async {
    final prompt = _promptTextController.text;
    final apiKey = _apiKeyTextController.text;

    if (prompt.isEmpty || apiKey.isEmpty) {
      // Show an error message if prompt or API key is empty
      showErrorDialog('Please enter a prompt and API key', context);
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      await Prefs.setString('gemini_api_key', apiKey);

      _generativeAI ??=
          GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text(prompt)];

      // Generate text using the Gemini model
      final response = await _generativeAI!.generateContent(content);

      // Update the response text field
      setState(() {
        _responseTextController.text = response.text ?? '';
        _isLoading = false; // Set loading state to false
      });
    } catch (e) {
      // Show an error message if there's an exception
      if (!mounted) return;
      showErrorDialog('Error: $e', context);
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  @override
  void dispose() {
    // Dispose all TextEditingController objects
    _promptTextController.dispose();
    _apiKeyTextController.dispose();
    _responseTextController.dispose();
    super.dispose();
  }
}
