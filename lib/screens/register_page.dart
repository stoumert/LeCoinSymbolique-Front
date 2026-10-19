import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'login_page.dart';
import 'verification_page.dart'; // à créer

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Champs du formulaire
  String username = '';
  String password = '';
  String confirmationPassword = '';
  String email = '';
  String fullName = '';
  String phoneNumber = '';
  String streetNumber = '';
  String streetName = '';
  String city = '';

  bool _obscurePassword = true;
  bool _obscureConfirmationPassword = true;
  bool isLoading = false;
  String? error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    // Construction de l'adresse complète
    String fullAddress = "$streetNumber $streetName $city";

    final success = await _authService.register(
      username,
      password,
      email,
      fullName,
      fullAddress, // Envoi de l'adresse combinée
      phoneNumber,

    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerificationPage(email: email)),
      );
    } else {
      setState(() {
        error = 'Erreur lors de l\'inscription';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              if (error != null) ...[
                Text(error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 12),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom complet'),
                onChanged: (value) => fullName = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Email invalide'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                onChanged: (value) => username = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                onChanged: (value) => password = value,
                validator: (value) => value != null && value.length < 7
                    ? 'Mot de passe trop court'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirmation mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmationPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmationPassword = !_obscureConfirmationPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmationPassword,
                onChanged: (value) => confirmationPassword = value,
                validator: (value) =>
                value != password ? 'Les mots de passe ne correspondent pas' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => phoneNumber = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ requis' : null,
              ),

              // Section Adresse - Début
              SizedBox(height: 16),
              Text('Adresse', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'N° de rue'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => streetNumber = value,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Nom de la rue'),
                      onChanged: (value) => streetName = value,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ville'),
                onChanged: (value) => city = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Requis' : null,
              ),
              // Section Adresse - Fin

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('S’inscrire'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text('Déjà un compte ? Connexion'),
              )
            ],
          ),
        ),
      ),
    );
  }
}