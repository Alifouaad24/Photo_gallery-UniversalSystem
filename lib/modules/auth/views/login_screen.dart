import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const _Header(),
                const SizedBox(height: 32),
                _LoginCard(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.photo_library_outlined, size: 72, color: Colors.deepPurple),
        SizedBox(height: 12),
        Text(
          'Photo Gallery',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text('سجّل دخولك للمتابعة', style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _LoginCard extends StatefulWidget {
  final AuthController controller;
  const _LoginCard({required this.controller});

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {


  @override
  void dispose() {
    widget.controller.emailCtrl.dispose();
    widget.controller.passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Input(
              controller: widget.controller.emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _Input(
              controller: widget.controller.passCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 24),
            GetBuilder<AuthController>(
              builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.loading
                        ? null
                        : () {
                            controller.login();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _Input({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
