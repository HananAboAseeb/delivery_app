import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  // Fixed Original Mock Data matching User's Exact Requirements
  final List<Map<String, dynamic>> _allStores = [
    {'name': 'السندباد', 'category': 'مطاعم', 'distance': 0.85, 'rating': 4.5, 'time': '30-45 دقيقة'},
    {'name': 'مطعم الاسطورة', 'category': 'مطاعم', 'distance': 0.92, 'rating': 3.2, 'time': '20-30 دقيقة'},
    {'name': 'الطماطم الأسري', 'category': 'مطاعم', 'distance': 1.5, 'rating': 4.7, 'time': '40-55 دقيقة'},
    {'name': 'كوفي شوب روز', 'category': 'كوفي شوب', 'distance': 0.6, 'rating': 4.8, 'time': '15-25 دقيقة'},
    {'name': 'بقالة العثيم', 'category': 'بقالة', 'distance': 1.2, 'rating': 4.6, 'time': '25-35 دقيقة'},
    {'name': 'سوبر ماركت مانويل', 'category': 'بقالة', 'distance': 0.9, 'rating': 4.9, 'time': '20-30 دقيقة'},
    {'name': 'صيدلية النهدي', 'category': 'صيدلية', 'distance': 1.8, 'rating': 4.5, 'time': '30-45 دقيقة'},
    {'name': 'هدايا ورد', 'category': 'تحف وهدايا', 'distance': 2.0, 'rating': 4.2, 'time': '45-60 دقيقة'},
  ];

  void _applyFiltersAndSort({
    String? category,
    String? filter,
    String? searchQuery,
    List<String>? currentFavorites,
  }) {
    final cat = category ?? state.selectedCategory;
    final filt = filter ?? state.selectedFilter;
    final q = searchQuery ?? state.searchQuery;
    final favs = currentFavorites ?? state.currentFavorites;

    List<Map<String, dynamic>> filteredList = List.from(_allStores);

    // 1. Filter by Category
    if (cat != 'الكل' && cat.isNotEmpty) {
      filteredList = filteredList.where((store) => store['category'] == cat).toList();
    }

    // 2. Real-time Text Search filtering
    if (q.trim().isNotEmpty) {
      filteredList = filteredList.where((store) => store['name'].toString().contains(q.trim())).toList();
    }

    // 3. Filter / Sort by Tab
    switch (filt) {
      case 'الأقرب':
        filteredList.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        break;
      case 'الجديدة':
        filteredList.shuffle(); // Mocking new items sorting
        break;
      case 'المفضلة':
        // Filter strictly by what's present in currentFavorites list
        filteredList = filteredList.where((store) => favs.contains(store['name'])).toList();
        break;
      case 'الكل':
      default:
        break;
    }

    emit(state.copyWith(
      selectedCategory: cat,
      selectedFilter: filt,
      searchQuery: q,
      currentFavorites: favs,
      stores: filteredList,
    ));
  }

  void selectCategory(String category) {
    final newCategory = (state.selectedCategory == category) ? 'الكل' : category;
    _applyFiltersAndSort(category: newCategory);
  }

  void selectFilter(String filter) {
    _applyFiltersAndSort(filter: filter);
  }

  void updateSearchQuery(String query) {
    _applyFiltersAndSort(searchQuery: query);
  }

  void syncFavorites(List<String> favStoreNames) {
    _applyFiltersAndSort(currentFavorites: favStoreNames);
  }

  void loadInitialData(List<String> initialFavs) {
    _applyFiltersAndSort(category: 'الكل', filter: 'الكل', searchQuery: '', currentFavorites: initialFavs);
  }
}
