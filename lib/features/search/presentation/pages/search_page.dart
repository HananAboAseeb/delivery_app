import 'package:flutter/material.dart';
import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/product/domain/entities/product_entity.dart';
import 'package:my_store/features/product/domain/repositories/product_repository.dart';
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/domain/repositories/store_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _isLoading = false;

  List<ProductEntity> _allProducts = [];
  List<StoreEntity> _allStores = [];
  bool _dataLoaded = false;

  final List<String> _recentSearches = ['برجر', 'شاورما', 'قهوة', 'صيدلية', 'بيتزا'];
  final List<String> _filters = ['الكل', 'المنتجات', 'المتاجر'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_dataLoaded) return;
    setState(() { _isLoading = true; });
    try {
      // Load products
      try {
        final productRepo = di.sl<ProductRepository>();
        _allProducts = await productRepo.getProducts(1, 100);
      } catch (e) {
        debugPrint('⚠️ [SearchPage] Products load failed: $e');
      }
      // Load stores
      try {
        final storeRepo = di.sl<StoreRepository>();
        _allStores = await storeRepo.getStores();
      } catch (e) {
        debugPrint('⚠️ [SearchPage] Stores load failed: $e');
      }
      _dataLoaded = true;
    } catch (e) {
      debugPrint('❌ [SearchPage] Unexpected error: $e');
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  List<ProductEntity> get _filteredProducts {
    if (_searchQuery.isEmpty) return [];
    return _allProducts.where((p) => p.name.contains(_searchQuery)).toList();
  }

  List<StoreEntity> get _filteredStores {
    if (_searchQuery.isEmpty) return [];
    return _allStores.where((s) => s.name.contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFFF4500);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('البحث', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              autofocus: false,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج أو متجر...',
                prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchQuery.isEmpty
              ? _buildRecentSearches(theme, primaryColor)
              : _buildSearchResults(theme, primaryColor),
    );
  }

  Widget _buildRecentSearches(ThemeData theme, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data status
          if (_allProducts.isNotEmpty || _allStores.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_allProducts.length} منتج و ${_allStores.length} متجر متاح للبحث',
                      style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          if (_allProducts.isEmpty && _allStores.isEmpty && _dataLoaded)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تأكد من تسجيل الدخول لعرض المنتجات',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _dataLoaded = false;
                      _loadData();
                    },
                    child: Text('إعادة', style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عمليات البحث الأخيرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('مسح الكل', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                label: Text(search),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
                onPressed: () {
                  _searchController.text = search;
                  setState(() => _searchQuery = search);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Quick browse products
          if (_allProducts.isNotEmpty) ...[
            const Text('منتجات متاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _allProducts.length > 10 ? 10 : _allProducts.length,
                itemBuilder: (context, index) {
                  final product = _allProducts[index];
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = product.name;
                      setState(() => _searchQuery = product.name);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.fastfood, color: primaryColor, size: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, Color primaryColor) {
    final products = _filteredProducts;
    final stores = _filteredStores;
    final showProducts = _selectedFilter == 'الكل' || _selectedFilter == 'المنتجات';
    final showStores = _selectedFilter == 'الكل' || _selectedFilter == 'المتاجر';
    final totalResults = (showProducts ? products.length : 0) + (showStores ? stores.length : 0);

    return Column(
      children: [
        // Filter tabs
        Container(
          color: Colors.white,
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                ),
              );
            },
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                '$totalResults نتيجة',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),

        Expanded(
          child: totalResults == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('لا توجد نتائج مطابقة', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Stores section
                    if (showStores && stores.isNotEmpty) ...[
                      Text('المتاجر (${stores.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...stores.map((store) => _buildStoreResultCard(store, primaryColor)),
                      const SizedBox(height: 16),
                    ],

                    // Products section
                    if (showProducts && products.isNotEmpty) ...[
                      Text('المنتجات (${products.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...products.map((product) => _buildProductResultCard(product, primaryColor)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStoreResultCard(StoreEntity store, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.store, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('متجر', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildProductResultCard(ProductEntity product, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.fastfood, color: primaryColor),
                    ),
                  )
                : Icon(Icons.fastfood, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${product.unitPrice.toStringAsFixed(0)} ${product.currencyName}',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.add_circle, color: primaryColor, size: 28),
        ],
      ),
    );
  }
}
