import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/camera_page.dart';
import 'screens/profile_page.dart';
import 'screens/login_page.dart';
import 'screens/community_page.dart';
import 'screens/create_post_page.dart';
import 'screens/history_page.dart';
import 'screens/plant_details_page.dart';
import 'screens/post_details_page.dart';
import 'screens/edit_profile_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await FirebaseFirestore.instance.collection('testes').add({
      'status': 'conectado',
      'data': DateTime.now().toString(),
    });
  } catch (e) {
    print(e);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/community': (context) => const CommunityPage(),
        '/home': (context) => const HomePage(),
        '/camera': (context) => const CameraPage(),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/create-post': (context) => const CreatePostPage(),
        '/history': (context) => const HistoryPage(),
        '/plant-details': (context) => const PlantDetailsPage(),
        '/post-details': (context) => const PostDetailsPage(),
        '/edit-profile': (context) => const EditProfilePage(),
      },
    );
  }
}
