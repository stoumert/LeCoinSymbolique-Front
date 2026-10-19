// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/screens/main_layout.dart';
import 'package:le_coin_symbolique_front/screens/password_miss_page_first.dart';
import 'package:le_coin_symbolique_front/screens/register_page.dart';
import '../service/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool _obscureText = true;
  bool isLoading = false;
  String error = '';

  void handleLogin() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    final success = await authService.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainLayout()),
      );
    } else {
      setState(() {
        error = 'Pseudo ou mot de passe incorrect';
      });
    }
  }

  void goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RegisterPage()),
    );
  }
  void goToPasswordMiss() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => PasswordMissPage()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Pseudo',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Se connecter'),
            ),
            TextButton(
              onPressed: goToRegister,
              child: Text("Pas encore de compte ? S'inscrire"),
            ),
            TextButton(onPressed: goToPasswordMiss,
                child: Text("Mot de passe oublié ?"))
          ],
        ),
      ),
    );
  }
}
