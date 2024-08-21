import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'image.dart';
import 'prefs.dart';
import 'ai.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  usePathUrlStrategy();
  await Prefs.init();
  await Supabase.initialize(
    url: 'https://owhhxmmvmwckvqjogbwt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aGh4bW12bXdja3Zxam9nYnd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM4NzQxODksImV4cCI6MjAzOTQ1MDE4OX0.5BXt9xlshBpARj2dG_WsU2rjebJiu6CF0vxBowkJo5g',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film DB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page!!'),
        '/image': (context) => const ImageScreen(),
        '/ai': (context) => const AiScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Credentials? _credentials;
  String? _data;

  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;

  late Auth0Web auth0;

  @override
  void initState() {
    super.initState();
    // auth0 = Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

    // auth0.onLoad().then((final credentials) => setState(() {
    //   // Handle or store credentials here
    //   _credentials = credentials;
    // }));
  }

  void fetchData() {
    supabase.from("movie").select().then((final data) => setState(() {
      _data = data.toString();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello, ${_credentials == null ? 'Guest' : _credentials!.user.email}',
            ),
            _data == null ? TextButton(onPressed: fetchData, child: const Text("Fetch Data")) : Text(_data!),
          ],
        ),
      ),
      
      
      // floatingActionButton: _credentials == null ? FloatingActionButton(
      //   onPressed: () => auth0.loginWithRedirect(redirectUrl: dotenv.env['AUTH0_REDIRECT_URL']!),
      //   tooltip: 'Log in',
      //   child: const Text("Log in"),
      // ) : null, // This trailing comma makes auto-formatting nicer for build methods.
      
    );
  }
}
