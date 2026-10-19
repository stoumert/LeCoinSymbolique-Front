import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/model/client_dto.dart';
import 'package:le_coin_symbolique_front/screens/conversation_page.dart';
import 'package:le_coin_symbolique_front/service/favoris_service.dart';
import 'package:le_coin_symbolique_front/service/image_service.dart';
import 'package:le_coin_symbolique_front/service/client_service.dart';

import '../service/annonce_service.dart';
import 'edit_annonce_page.dart';

class AnnonceDetailPage extends StatefulWidget {
  final AnnonceDTO annonce;

  const AnnonceDetailPage({super.key, required this.annonce});

  @override
  State<AnnonceDetailPage> createState() => _AnnonceDetailPageState();
}

class _AnnonceDetailPageState extends State<AnnonceDetailPage> {
  int _currentImageIndex = 0;
  late PageController _pageController;
  bool isFavoris = false;
  bool isLoading = false;
  ClientDTO? _currentUser;
  final FavorisService _favorisService = FavorisService();
  final ImageService _imageService = ImageService();
  final ClientService _clientService = ClientService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFavoriStatus();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _clientService.getCurrentUser();
      if (mounted) {
        setState(() => _currentUser = user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkFavoriStatus() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final isFav = await _favorisService.isFavori(widget.annonce.id ?? 0);
      if (mounted) {
        setState(() => isFavoris = isFav);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleFavori() async {
    if (!mounted || isLoading) return;

    setState(() => isLoading = true);
    final newFavStatus = !isFavoris;

    try {
      if (newFavStatus) {
        await _favorisService.addFavori(widget.annonce.id!);
      } else {
        await _favorisService.removeFavori(widget.annonce.id!);
      }

      if (mounted) {
        setState(() => isFavoris = newFavStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _editAnnonce() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnnoncePage(
          annonce: widget.annonce,
          onUpdate: () {
            // Rafraîchir la liste des annonces si nécessaire
          },
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirection vers la page de modification')),
    );
  }

  Future<void> _deleteAnnonce() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AnnonceService().deleteAnnonce(widget.annonce.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce supprimée avec succès')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _currentUser != null &&
        widget.annonce.client != null &&
        _currentUser!.id == widget.annonce.client!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.annonce.title),
        actions: [
          if (!isOwner)
            IconButton(
              icon: isLoading
                  ? const CircularProgressIndicator()
                  : Icon(
                isFavoris ? Icons.favorite : Icons.favorite_border,
                color: isFavoris ? Colors.red : null,
              ),
              onPressed: _toggleFavori,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.annonce.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${widget.annonce.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Votre annonce',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.annonce.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(isOwner),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildContactButton(isOwner),
    );
  }

  Widget _buildImageSlider() {
    final images = widget.annonce.imageUrls ?? [];

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return FutureBuilder<ImageProvider>(
                future: _imageService.getImageProvider(images[index].url),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image(
                      image: snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(
          icon: Icons.category,
          label: 'Catégorie',
          value: widget.annonce.produit.type_produit.name,
        ),
        _buildInfoItem(
          icon: Icons.person,
          label: 'Vendeur',
          value: '${widget.annonce.client!.username}${isOwner ? ' (Vous)' : ''}',
        ),
        _buildInfoItem(
            icon: Icons.label,
            label: "État",
            value: widget.annonce.produit.etat.toString()),
        _buildInfoItem(
          icon: Icons.calendar_today,
          label: 'Date de publication',
          value: _formatDate(widget.annonce.createdAt.toString()),
        ),
        _buildInfoItem(
          icon: Icons.phone,
          label: 'Contact',
          value: widget.annonce.phoneNumber.toString(),
        ),
        _buildInfoItem(
            icon: Icons.date_range,
            label: 'Année', 
            value: widget.annonce.produit.annee.toString()
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(bool isOwner) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isOwner
          ? Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
              onPressed: _editAnnonce,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Supprimer'),
              onPressed: _deleteAnnonce,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
        ],
      )
          : ElevatedButton.icon(
        icon: const Icon(Icons.message),
        label: const Text('Contacter le vendeur'),
        onPressed: () {
          if (_currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Veuillez vous connecter pour contacter le vendeur')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                interlocuteurId: widget.annonce.client!.id,
                interlocuteurName: widget.annonce.client!.username,
                annonceId: widget.annonce.id,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}