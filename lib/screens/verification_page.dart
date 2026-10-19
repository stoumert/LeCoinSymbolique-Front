// lib/screens/verification_page.dart
import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'login_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  VerificationPage({required this.email});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final codeController = TextEditingController();
  final authService = AuthService();

  String error = '';
  bool isLoading = false;

  void handleVerification() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    final success = await authService.verifyCode(
      widget.email,
      codeController.text.trim(),
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
        error = 'Code incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérification du code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Un code a été envoyé à ${widget.email}'),
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Code à 6 chiffres'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : handleVerification,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
