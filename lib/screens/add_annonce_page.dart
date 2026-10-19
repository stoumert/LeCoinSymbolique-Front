import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:le_coin_symbolique_front/model/produit.dart';
import 'package:le_coin_symbolique_front/model/produit/jeu_video.dart';
import 'package:le_coin_symbolique_front/model/produit/livre.dart';
import 'package:le_coin_symbolique_front/model/produit/outil.dart';
import 'package:le_coin_symbolique_front/model/produit/vetement.dart';
import 'package:le_coin_symbolique_front/screens/profile_page.dart';
import 'package:le_coin_symbolique_front/service/annonce_service.dart';

import '../model/annonce_dto.dart';
import '../model/produit/electronique.dart';
import '../model/produit/meuble.dart';
import '../model/produit/type_produit.dart';

class AjoutPage extends StatefulWidget {
  const AjoutPage({super.key});

  @override
  State<AjoutPage> createState() => _AjoutPageState();
}

class _AjoutPageState extends State<AjoutPage> {
  final _formKey = GlobalKey<FormState>();
  final AnnonceService _annonceService = AnnonceService();

  String _title = '';
  String _description = '';
  double _price = 0;
  String _etat = 'neuf';
  int _annee = DateTime.now().year;

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  TypeProduit _selectedType = TypeProduit.ELECTRONIQUE;
  final Map<String, dynamic> _produitData = {};

  final List<String> _etats = ['neuf', 'très bon', 'bon', 'mauvais'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une annonce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),

              _buildProductTypeSection(),
              const SizedBox(height: 20),

              _buildProductSpecificFields(),
              const SizedBox(height: 20),

              _buildImageSection(),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Publier l\'annonce'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de base',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Titre'),
          validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
          onSaved: (value) => _title = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
          validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
          onSaved: (value) => _description = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Prix'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Champ obligatoire';
            final price = double.tryParse(value);
            if (price == null) return 'Prix invalide';

            final maxPrice = _getMaxPriceForCategory();
            if (price > maxPrice) {
              return 'Le prix max pour cette catégorie est $maxPrice €';
            }
            return null;
          },
          onSaved: (value) => _price = double.parse(value!),
        ),
      ],
    );
  }

  double _getMaxPriceForCategory() {
    switch (_selectedType) {
      case TypeProduit.ELECTRONIQUE: return 50.0;
      case TypeProduit.MEUBLE: return 30.0;
      case TypeProduit.JEUVIDEO: return 5.0;
      case TypeProduit.LIVRE: return 5.0;
      case TypeProduit.VETEMENT: return 10.0;
      case TypeProduit.OUTIL: return 20.0;
      default: return 1.0;
    }
  }

  Widget _buildProductTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de produit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButtonFormField<TypeProduit>(
          value: _selectedType,
          items: TypeProduit.values.map((type) {
            return DropdownMenuItem<TypeProduit>(
              value: type,
              child: Text(_getTypeProduitDisplayName(type)),
            );
          }).toList(),
          onChanged: (TypeProduit? newValue) {
            setState(() {
              _selectedType = newValue!;
              _produitData.clear();
            });
          },
          decoration: const InputDecoration(labelText: 'Catégorie'),
        ),
      ],
    );
  }

  Widget _buildProductSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du produit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Sélecteur d'état
        DropdownButtonFormField<String>(
          value: _etat,
          items: _etats.map((etat) {
            return DropdownMenuItem<String>(
              value: etat,
              child: Text(etat),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'État'),
          onChanged: (value) => setState(() => _etat = value!),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Année'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Champ obligatoire';
            final year = int.tryParse(value);
            if (year == null) return 'Année invalide';
            if (year < 1900 || year > DateTime.now().year + 1) {
              return 'Année doit être entre 1900 et ${DateTime.now().year + 1}';
            }
            return null;
          },
          onSaved: (value) => _annee = int.parse(value!),
          initialValue: _annee.toString(),
        ),
        ..._getSpecificFieldsForProductType(),
      ],
    );
  }

  Produit _createProduitFromData() {
    final commonData = {
      'etat': _etat,
      'annee': _annee,
    };

    final productData = {...commonData, ..._produitData};

    switch (_selectedType) {
      case TypeProduit.ELECTRONIQUE:
        return ProduitElectronique(
          etat: productData['etat'],
          annee: productData['annee'],
          type: productData['type'],
          marque: productData['marque'],
          modele: productData['modele'],
          taille: productData['taille'],
        );
      case TypeProduit.MEUBLE:
        return ProduitMeuble(
          etat: productData['etat'],
          annee: productData['annee'],
          matiere: productData['matiere'],
          dimensions: productData['dimensions'],
        );
      case TypeProduit.JEUVIDEO:
        return ProduitJeuVideo(
          etat: productData['etat'],
          annee: productData['annee'],
          titreJeu: productData['titreJeu'],
          plateforme: productData['plateforme'],
          editeur: productData['editeur'],
        );
      case TypeProduit.LIVRE:
        return ProduitLivre(
          etat: productData['etat'],
          annee: productData['annee'],
          titreLivre: productData['titreLivre'],
          auteur: productData['auteur'],
          anneePublication: productData['anneePublication'],
        );
      case TypeProduit.VETEMENT:
        return ProduitVetement(
          etat: productData['etat'],
          annee: productData['annee'],
          type: productData['type'],
          genre: productData['genre'],
          taille: productData['taille'],
          marque: productData['marque'],
        );
      case TypeProduit.OUTIL:
        return ProduitOutil(
          etat: productData['etat'],
          annee: productData['annee'],
          type: productData['type'],
          puissance: productData['puissance'],
          marque: productData['marque'],
          modele: productData['modele'],
        );
      case TypeProduit.AUTRE:
        throw UnimplementedError();
    }
  }

  List<Widget> _getSpecificFieldsForProductType() {
    switch (_selectedType) {
      case TypeProduit.ELECTRONIQUE:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Type'),
            onSaved: (value) => _produitData['type'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Marque'),
            onSaved: (value) => _produitData['marque'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Modèle'),
            onSaved: (value) => _produitData['modele'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'taille'),
            keyboardType : TextInputType.number,
            onSaved: (value) => _produitData['taille'] = value,
          ),
        ];
      case TypeProduit.MEUBLE:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Matière'),
            onSaved: (value) => _produitData['matiere'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Dimensions'),
            onSaved: (value) => _produitData['dimensions'] = value,
          ),
        ];
      case TypeProduit.JEUVIDEO:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Titre du jeu'),
            onSaved: (value) => _produitData['titreJeu'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Plateforme'),
            onSaved: (value) => _produitData['plateforme'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Éditeur'),
            onSaved: (value) => _produitData['editeur'] = value,
          ),
        ];
      case TypeProduit.LIVRE:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Titre du livre'),
            onSaved: (value) => _produitData['titreLivre'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Auteur'),
            onSaved: (value) => _produitData['dimensions'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Année Publication'),
            keyboardType : TextInputType.number,
            onSaved: (value) => _produitData['anneePublication'] = value,
          ),
        ];
      case TypeProduit.VETEMENT:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Type'),
            onSaved: (value) => _produitData['type'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Genre'),
            onSaved: (value) => _produitData['genre'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Taille'),
            onSaved: (value) => _produitData['taille'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Marque'),
            onSaved: (value) => _produitData['marque'] = value,
          ),
        ];
      case TypeProduit.OUTIL:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Type'),
            onSaved: (value) => _produitData['type'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Puissance'),
            onSaved: (value) => _produitData['puissance'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Marque'),
            onSaved: (value) => _produitData['marque'] = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Modèle'),
            onSaved: (value) => _produitData['modele'] = value,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._images.map((file) => Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _images.remove(file)),
                  ),
                ),
              ],
            )),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_a_photo, size: 40),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  String _getTypeProduitDisplayName(TypeProduit type) {
    switch (type) {
      case TypeProduit.ELECTRONIQUE: return 'Électronique';
      case TypeProduit.MEUBLE: return 'Meuble';
      case TypeProduit.OUTIL: return 'Outil';
      case TypeProduit.VETEMENT: return 'Vêtement';
      case TypeProduit.LIVRE: return 'Livre';
      case TypeProduit.JEUVIDEO: return 'Jeu vidéo';
      default: return 'Autre';
    }
  }



  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final produit = _createProduitFromData();
        final annonce = AnnonceDTO(
          title: _title,
          description: _description,
          price: _price,
          status: 'ACTIVE',
          createdAt: DateTime.now(),
          produit: produit,
          phoneNumber: null,
          client: null,
        );

        final response = await _annonceService.createAnnonce(
          annonce: annonce,
          images: _images,
        );

        if (response && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Annonce créée avec succès!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ProfilePage()),
                  (Route<dynamic> route) => false,
          );

        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }
}