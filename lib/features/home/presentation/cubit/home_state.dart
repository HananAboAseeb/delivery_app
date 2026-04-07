part of 'home_cubit.dart';

class HomeState extends Equatable {
  final String selectedCategory;
  final String selectedFilter;
  final String searchQuery;
  final List<String> currentFavorites;
  final List<Map<String, dynamic>> stores;

  const HomeState({
    required this.selectedCategory,
    required this.selectedFilter,
    required this.searchQuery,
    required this.currentFavorites,
    required this.stores,
  });

  factory HomeState.initial() {
    return const HomeState(
      selectedCategory: 'الكل',
      selectedFilter: 'الكل',
      searchQuery: '',
      currentFavorites: [],
      stores: [],
    );
  }

  HomeState copyWith({
    String? selectedCategory,
    String? selectedFilter,
    String? searchQuery,
    List<String>? currentFavorites,
    List<Map<String, dynamic>>? stores,
  }) {
    return HomeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentFavorites: currentFavorites ?? this.currentFavorites,
      stores: stores ?? this.stores,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, selectedFilter, searchQuery, currentFavorites, stores];
}
