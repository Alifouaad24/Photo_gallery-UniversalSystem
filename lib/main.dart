import 'package:flutter/material.dart';
import 'package:photo_gallery/screens/home-screen.dart';
import 'package:photo_gallery/services/permission_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PermissionService.requestCameraAndStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData.dark(),
    );
  }
}
