import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/screens/password_miss_page_second.dart';
import 'package:le_coin_symbolique_front/service/auth_service.dart';

import 'login_page.dart';

class PasswordMissPage extends StatefulWidget {
  @override
  _PasswordMissPageState createState() => _PasswordMissPageState();
}

class _PasswordMissPageState extends State<PasswordMissPage> {
  final AuthService authService = AuthService();
  final TextEditingController email = TextEditingController();
  bool isLoading = false;
  String error = '';

  void handlePasswordMiss() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    final success = await authService.mot_de_passe_oublie(email.text.trim());
    print('$success');
    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PasswordMissPageSecond(email: email.text.trim())),
      );
    } else {
      setState(() {
        error = 'Une erreur est survenue. Veuillez vérifier l’email.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: handlePasswordMiss,
              child: Text('Réinitialiser le mot de passe'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: Text('Se connecter'),
            )
          ],
        ),
      ),
    );
  }
}
