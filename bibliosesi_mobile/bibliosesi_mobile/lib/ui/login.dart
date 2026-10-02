import 'package:flutter/material.dart';

import '../root/pallet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  void entrar() {
    Navigator.pushReplacementNamed(
      context,
      '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),

            child: Column(
              children: [
                const Icon(
                  Icons.local_library,
                  color: AppPalette.primary,
                  size: 75,
                ),

                const SizedBox(height: 15),

                const Text(
                  'BiblioSesi',
                  style: TextStyle(
                    color: AppPalette.primary,
                    fontSize: 32,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'E-mail',

                    prefixIcon: const Icon(
                      Icons.email,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: senhaController,
                  obscureText: true,

                  decoration: InputDecoration(
                    labelText: 'Senha',

                    prefixIcon: const Icon(
                      Icons.lock,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(
                    onPressed: entrar,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                    ),

                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

