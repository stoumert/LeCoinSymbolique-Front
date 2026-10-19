import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';
import 'package:le_coin_symbolique_front/service/annonce_service.dart';

import '../service/image_service.dart';

class EditAnnoncePage extends StatefulWidget {
  final AnnonceDTO annonce;
  final VoidCallback? onUpdate;

  const EditAnnoncePage({
    super.key,
    required this.annonce,
    this.onUpdate,
  });

  @override
  State<EditAnnoncePage> createState() => _EditAnnoncePageState();
}

class _EditAnnoncePageState extends State<EditAnnoncePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  final _formKey = GlobalKey<FormState>();
  final AnnonceService _annonceService = AnnonceService();
  final ImageService _imageService = ImageService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.annonce.title);
    _descriptionController = TextEditingController(text: widget.annonce.description);
    _priceController = TextEditingController(text: widget.annonce.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.annonce.imageUrls?.isNotEmpty ?? false
                ? Image.network(
              widget.annonce.imageUrls!.first.url,
              fit: BoxFit.cover,
              width: double.infinity,
            )
                : Center(
              child: Icon(
                Icons.camera_alt,
                size: 50,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Titre*',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un titre';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Prix* (€)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.euro),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un prix';
        }
        if (double.tryParse(value) == null) {
          return 'Prix invalide';
        }

        // Validation du prix selon la catégorie
        final price = double.parse(value);
        final maxPrice = _getMaxPriceForCategory();
        if (price > maxPrice) {
          return 'Le prix max pour cette catégorie est $maxPrice €';
        }
        return null;
      },
    );
  }

  double _getMaxPriceForCategory() {
    final type = widget.annonce.produit.type_produit;
    switch (type) {
      case TypeProduit.ELECTRONIQUE: return 50.0;
      case TypeProduit.MEUBLE: return 30.0;
      case TypeProduit.JEUVIDEO: return 5.0;
      case TypeProduit.LIVRE: return 5.0;
      case TypeProduit.VETEMENT: return 10.0;
      case TypeProduit.OUTIL: return 20.0;
      default: return 1.0;
    }
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      minLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Enregistrer les modifications',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await _annonceService.update(
          id: widget.annonce.id!,
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
        );

        if (success) {
          if (widget.onUpdate != null) {
            widget.onUpdate!();
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Annonce mise à jour avec succès!')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}