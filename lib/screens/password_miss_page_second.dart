import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/screens/login_page.dart';
import 'package:le_coin_symbolique_front/service/auth_service.dart';

class PasswordMissPageSecond extends StatefulWidget {
  final String email;

  PasswordMissPageSecond({required this.email});
  @override
  _PasswordMissPageSecondState createState() => _PasswordMissPageSecondState();
}

class _PasswordMissPageSecondState extends State<PasswordMissPageSecond> {
  final AuthService authService = AuthService();
  final TextEditingController codeValidation = TextEditingController();
  final TextEditingController newPassword = TextEditingController();

  bool isLoading = false;
  String error = '';

  void handlePasswordMiss() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    final success = await authService.newPassword(
        codeValidation.text,
        newPassword.text,
        widget.email
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
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
              controller: codeValidation,
              decoration: InputDecoration(labelText: 'Code à 6 chiffres'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: newPassword,
              decoration: InputDecoration(labelText: 'nouveau mot de passe'),
              obscureText: true,
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
          ],
        ),
      ),
    );
  }
}
