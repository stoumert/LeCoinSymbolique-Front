import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/service/favoris_service.dart';
import 'package:le_coin_symbolique_front/service/image_service.dart';

import '../../model/annonce_dto.dart';
import '../annonce_detail_page.dart';

class AnnonceCard extends StatefulWidget {
  final AnnonceDTO annonce;
  final VoidCallback? onUpdate;

  const AnnonceCard({
    super.key,
    required this.annonce,
    this.onUpdate,
  });

  @override
  State<AnnonceCard> createState() => _AnnonceCardState();
}

class _AnnonceCardState extends State<AnnonceCard> {
  bool isFavoris = false;
  bool isLoading = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  final FavorisService _favorisService = FavorisService();
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFavoriStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        await _favorisService.addFavori(widget.annonce.id ?? 0);
      } else {
        await _favorisService.removeFavori(widget.annonce.id ?? 0);
      }

      if (mounted) {
        setState(() => isFavoris = newFavStatus);
        widget.onUpdate?.call();
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnonceDetailPage(
              annonce: widget.annonce,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.black26,
        child: Column(
          children: [
            _buildImageSection(),
            _buildInfoSection(widget.annonce),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: _buildImageContent(),
        ),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildImageContent() {
    final images = (widget.annonce.imageUrls) ?? [];

    if (images.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
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
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                    child: Image(
                      image: snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  );
                }
                return _buildPlaceholder();
              },
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
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
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          )
              : Icon(
            isFavoris ? Icons.favorite : Icons.favorite_border,
            color: isFavoris ? Colors.red : Colors.grey[700],
          ),
          onPressed: _toggleFavori,
        ),
      ),
    );
  }

  Widget _buildInfoSection(AnnonceDTO annonce) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  annonce.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${annonce.price} €',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            annonce.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _buildMetaData(annonce),
        ],
      ),
    );
  }

  Widget _buildMetaData(AnnonceDTO annonce) {
    return Column(
      children: [
        _buildMetaItem(
          icon: Icons.category,
          iconColor: Colors.orange,
          text: 'Type: ${annonce.produit.type_produit.name}',
        ),
        _buildMetaItem(
          icon: Icons.person,
          iconColor: Colors.blueGrey,
          text: 'Par ${annonce.client?.username?? 'Utilisateur'}',
        ),
        _buildMetaItem(
          icon: Icons.calendar_today,
          iconColor: Colors.deepPurple,
          text: 'Ajoutée le ${_formatDate(annonce.createdAt.toString())}',
        ),
        if (annonce.phoneNumber != null)
          _buildMetaItem(
            icon: Icons.phone,
            iconColor: Colors.green[800],
            text: annonce.phoneNumber.toString(),
          ),
      ],
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required Color? iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      return dateString.split('T').first;
    } catch (e) {
      return dateString;
    }
  }
}