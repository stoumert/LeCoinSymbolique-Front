import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/model/client_dto.dart';
import 'package:le_coin_symbolique_front/service/annonce_service.dart';
import 'package:le_coin_symbolique_front/service/client_service.dart';

import 'card/annonce_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AnnonceService _annonceService = AnnonceService();
  final ClientService _clientService = ClientService();
  late Future<ClientDTO?> _userFuture;
  late Future<List<AnnonceDTO>> _annoncesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userFuture = _clientService.getCurrentUser();
    _annoncesFuture = _userFuture.then((user) {
      return user != null
          ? _annonceService.getAnnonceByUserId(user.id, 0)
          : Future.value([]);
    });
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  // Fonction pour générer une couleur basée sur l'initiale
  Color _getAvatarColor(String initial) {
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
    ];
    final index = initial.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<ClientDTO?>(
          future: _userFuture,
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError || userSnapshot.data == null) {
              return Center(
                child: Text(
                  userSnapshot.hasError
                      ? 'Erreur: ${userSnapshot.error}'
                      : 'Utilisateur non connecté',
                ),
              );
            }

            final user = userSnapshot.data!;
            final initial = user.username.isNotEmpty
                ? user.username[0].toUpperCase()
                : '?';
            final avatarColor = _getAvatarColor(initial);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: avatarColor,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildUserInfoSection(user),
                  const SizedBox(height: 24),
                  _buildAnnoncesSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(ClientDTO user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.person, 'Nom complet', user.fullName),
            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(Icons.account_circle, 'Pseudonyme', user.username),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnoncesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes Annonces',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<AnnonceDTO>>(
          future: _annoncesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final annonces = snapshot.data ?? [];

            if (annonces.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune annonce publiée',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: annonces.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnnonceCard(
                    annonce: annonces[index],
                    onUpdate: _refresh,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}