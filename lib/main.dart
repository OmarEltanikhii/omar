import 'package:flutter/material.dart';
import 'package:look_mobile_app/screens/gallery_screen.dart';
import 'package:look_mobile_app/screens/history_screen.dart';
import 'package:look_mobile_app/screens/home_screen.dart';
import 'package:look_mobile_app/screens/profile_screen.dart';
import 'package:look_mobile_app/screens/signup_screen.dart';
import 'package:look_mobile_app/screens/welcom.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOOK!',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        //'/camera': (context) => CameraScreen()
        '/profile': (context) => ProfileScreen(),
        '/gallery': (context) => GalleryScreen(),
        '/history': (context) => HistoryScreen(),
      },
    );
  }
}
