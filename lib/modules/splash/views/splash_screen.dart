import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/routes/app_routes.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
 
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (controller) =>
       Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.photo_library_outlined,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Photo Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
