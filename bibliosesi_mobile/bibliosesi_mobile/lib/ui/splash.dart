import 'dart:async';

import 'package:flutter/material.dart';

import '../root/pallet.dart';
import 'login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.local_library,
              color: Colors.white,
              size: 85,
            ),

            SizedBox(height: 20),

            Text(
              'BiblioSesi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Biblioteca Virtual',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
