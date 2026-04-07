import 'package:flutter/material.dart';
import 'package:my_store/features/home/presentation/widgets/store_card_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _recentSearches = ['برجر', 'شاورما', 'قهوة', 'صيدلية', 'بيتزا'];
  final List<String> _filters = ['الكل', 'مطاعم', 'كوفي شوب', 'بقالة', 'صيدلية'];

  final List<Map<String, dynamic>> _mockResults = [
    {'name': 'برجر كينج', 'category': 'مطاعم', 'distance': '1.2 كم', 'rating': 4.3, 'time': '20-30 دقيقة'},
    {'name': 'ماكدونالدز', 'category': 'مطاعم', 'distance': '2.0 كم', 'rating': 4.1, 'time': '15-25 دقيقة'},
    {'name': 'شاورمجي', 'category': 'مطاعم', 'distance': '0.5 كم', 'rating': 4.6, 'time': '10-20 دقيقة'},
    {'name': 'ستاربكس', 'category': 'كوفي شوب', 'distance': '1.5 كم', 'rating': 4.8, 'time': '10-15 دقيقة'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Map<String, dynamic>> activeResults = [];

    if (_searchQuery.isNotEmpty) {
      activeResults = _mockResults.where((store) {
        final matchesQuery = store['name'].toString().contains(_searchQuery);
        final matchesCategory = _selectedFilter == 'الكل' || store['category'] == _selectedFilter;
        return matchesQuery && matchesCategory;
      }).toList();
    }

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
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'عن ماذا تبحث؟',
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
      body: _searchQuery.isEmpty ? _buildRecentSearches(theme) : _buildSearchResults(theme, activeResults),
    );
  }

  Widget _buildRecentSearches(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text('الفئات المقترحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters.skip(1).map((filter) {
              return ChoiceChip(
                label: Text(filter),
                selected: false,
                onSelected: (val) {
                  setState(() {
                    _selectedFilter = filter;
                    _searchQuery = filter; // Mocking shortcut query
                    _searchController.text = filter;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, List<Map<String, dynamic>> results) {
    return Column(
      children: [
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
                  selectedColor: theme.primaryColor,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: results.isEmpty
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
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final store = results[index];
                    return StoreCardWidget(
                      name: store['name'],
                      category: store['category'],
                      distance: store['distance'],
                      rating: store['rating'].toDouble(),
                      deliveryTime: store['time'],
                      onTap: () {},
                    );
                  },
                ),
        ),
      ],
    );
  }
}
