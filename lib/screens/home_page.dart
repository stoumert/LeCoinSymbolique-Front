import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/service/annonce_service.dart';
import 'card/annonce_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController(text: '10');

  final AnnonceService _annonceService = AnnonceService();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'Toutes catégories';
  final List<String> _categories = [
    'Toutes catégories',
    'Électronique',
    'Livres',
    'Vêtements',
    'Meuble',
    'Autre'
  ];

  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  final List<String> _sortOptions = ['createdAt', 'price'];
  final List<String> _sortDirs = ['asc', 'desc'];

  List<AnnonceDTO> _annonces = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showFilters = false;

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInitialAnnonces();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _addressController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAnnonces() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      double? minPrice = _parseDouble(_minPriceController.text);
      double? maxPrice = _parseDouble(_maxPriceController.text);

      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        throw Exception('Le prix minimum ne peut pas être supérieur au prix maximum');
      }

      final results = await _annonceService.searchAnnonces(
        title: _searchController.text.trim(),
        typeProduit: _selectedCategory != 'Toutes catégories' ? _selectedCategory : null,
        minPrice: minPrice,
        maxPrice: maxPrice,
        adresse: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        radiusKm: _parseDouble(_radiusController.text) ?? 10.0,
        page: 0,
        size: _itemsPerPage,
        sortedBy: _sortBy,
        sortedDir: _sortDir,
      );

      setState(() {
        _annonces = results.map((json) => AnnonceDTO.fromJson(json)).toList();
        _currentPage = 0;
        _hasMore = results.length >= _itemsPerPage;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAnnonces() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final results = await _annonceService.searchAnnonces(
        title: _searchController.text.trim(),
        typeProduit: _selectedCategory != 'Toutes catégories' ? _selectedCategory : null,
        minPrice: _parseDouble(_minPriceController.text),
        maxPrice: _parseDouble(_maxPriceController.text),
        adresse: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        radiusKm: _parseDouble(_radiusController.text) ?? 10.0,
        page: nextPage,
        size: _itemsPerPage,
        sortedBy: _sortBy,
        sortedDir: _sortDir,
      );

      setState(() {
        _annonces.addAll(results.map((json) => AnnonceDTO.fromJson(json)));
        _currentPage = nextPage;
        _hasMore = results.length >= _itemsPerPage;
      });
    } catch (e) {
      debugPrint('Erreur de chargement supplémentaire : $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  double? _parseDouble(String text) {
    return text.isNotEmpty ? double.tryParse(text.replaceAll(',', '.')) : null;
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      _loadMoreAnnonces();
    }
  }

  void _performSearch() {
    _loadInitialAnnonces();
  }

  void _clearFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _addressController.clear();
    _radiusController.text = '10';
    setState(() {
      _selectedCategory = 'Toutes catégories';
      _sortBy = 'createdAt';
      _sortDir = 'desc';
    });
    _loadInitialAnnonces();
  }

  Widget _buildAnnoncesList() {
    if (_isLoading && _annonces.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    } else if (_annonces.isEmpty) {
      return const Center(child: Text("Aucune annonce trouvée"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _annonces.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _annonces.length) {
          return AnnonceCard(annonce: _annonces[index]);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.search),
                ),
                IconButton(
                  icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                    //if (!_showFilters) _performSearch();
                  },
                  tooltip: _showFilters ? 'Masquer filtres' : 'Afficher filtres',
                ),
              ],
            ),
          ),
          if (_showFilters) ...[
            _buildFiltersSection(),
            const SizedBox(height: 8),
          ],
          Expanded(child: _buildAnnoncesList()),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 7),
                    ),
                    items: _categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Localisation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prix min (€)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prix max (€)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Rayon (km)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: InputDecoration(
                      labelText: 'Trier par',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _sortOptions.map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(option == 'createdAt' ? 'Date' : 'Prix'),
                    )).toList(),
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortDir,
                    decoration: InputDecoration(
                      labelText: 'Ordre',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _sortDirs.map((dir) => DropdownMenuItem(
                      value: dir,
                      child: Text(dir == 'asc' ? 'Croissant' : 'Décroissant'),
                    )).toList(),
                    onChanged: (value) => setState(() => _sortDir = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}