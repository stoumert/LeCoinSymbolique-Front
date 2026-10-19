import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/service/favoris_service.dart';

import 'card/annonce_card.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  final FavorisService _favorisService = FavorisService();
  List<dynamic> _favoris = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    try {
      final data = await _favorisService.getFavoris();
      setState(() {
        _favoris = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des favoris : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoris.isEmpty
          ? const Center(child: Text('Aucune annonce en favori.'))
          : RefreshIndicator(
        onRefresh: _loadFavoris,
        child: ListView.builder(
          itemCount: _favoris.length,
          itemBuilder: (context, index) {
            final annonce = _favoris[index];
            final annonceDto = AnnonceDTO.fromJson(annonce);

            return Dismissible(
              key: Key(annonceDto.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                try {
                  await _favorisService.removeFavori(annonceDto.id ?? 0);
                  setState(() {
                    _favoris.removeAt(index);
                  });
                } catch (e) {
                  print("Erreur suppression favori : $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Erreur de suppression")),
                  );
                }
              },
              child: AnnonceCard(annonce: annonceDto),
            );
          },
        ),
      ),
    );
  }
}
