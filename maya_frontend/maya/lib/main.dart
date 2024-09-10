import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maya/screens/daily_diary.dart';
import 'package:maya/screens/health.dart';
import 'package:maya/screens/home_screen.dart';
import 'package:maya/screens/lists_home.dart';
import 'package:maya/screens/login_screen.dart';
import 'package:maya/screens/more.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD2ylM8fpNVn2MLrPUTHhI9jdGdEzx9M-4",
        appId: "1:280733294443:android:10e6b02c82110ca2cf762e",
        messagingSenderId: "280733294443",
        projectId: "maya-229e0"
      )
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

User? user = FirebaseAuth.instance.currentUser;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'ClashGrotesk'),
          bodyMedium: TextStyle(fontFamily: 'ClashGrotesk'),
          displayLarge: TextStyle(fontFamily: 'ClashGrotesk'),
          displayMedium: TextStyle(fontFamily: 'ClashGrotesk'),
          displaySmall: TextStyle(fontFamily: 'ClashGrotesk'),
          headlineMedium: TextStyle(fontFamily: 'ClashGrotesk'),
          headlineSmall: TextStyle(fontFamily: 'ClashGrotesk'),
          titleLarge: TextStyle(fontFamily: 'ClashGrotesk'),
          titleMedium: TextStyle(fontFamily: 'ClashGrotesk'),
          titleSmall: TextStyle(fontFamily: 'ClashGrotesk'),
          bodySmall: TextStyle(fontFamily: 'ClashGrotesk'),
          labelLarge: TextStyle(fontFamily: 'ClashGrotesk'),
          labelSmall: TextStyle(fontFamily: 'ClashGrotesk'),
        ),
      ),
      home: const VideoSplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(title: ''), // Define login screen route
      },
    );
  }
}

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('lib/utils/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {}); 
        _controller.play(); 
        _timer = Timer(const Duration(seconds: 3), () {
          _controller.pause(); 
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _controller.pause();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()), // Removed title parameter
            );
          } else {
            _controller.pause();
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.pause(); // Pause the video
    _controller.dispose(); // Dispose the video controller
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [];

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HealthScreen(),
    ListsHome(),
    DailyDiaryScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _navigationHistory.add(_selectedIndex);
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.isNotEmpty) {
      setState(() {
        _selectedIndex = _navigationHistory.removeLast();
      });
      return Future.value(false);
    } else {
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      )) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety),
              label: 'Food & Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Lists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Daily Diary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
