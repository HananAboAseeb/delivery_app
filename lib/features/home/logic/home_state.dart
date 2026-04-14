part of 'home_cubit.dart';

class HomeState extends Equatable {
  final String selectedCategory;
  final String? selectedGroupId;
  final String selectedFilter;
  final String searchQuery;
  final List<String> currentFavorites;
  final List<StoreEntity> stores;
  final List<StoreGroupEntity> storeGroups;
  final List<ProductEntity> products;
  final bool isLoadingGroups;
  final bool isLoadingStores;
  final bool isLoadingProducts;
  final String? errorMessage;

  const HomeState({
    required this.selectedCategory,
    this.selectedGroupId,
    required this.selectedFilter,
    required this.searchQuery,
    required this.currentFavorites,
    required this.stores,
    required this.storeGroups,
    required this.products,
    this.isLoadingGroups = false,
    this.isLoadingStores = false,
    this.isLoadingProducts = false,
    this.errorMessage,
  });

  factory HomeState.initial() {
    return const HomeState(
      selectedCategory: 'الكل',
      selectedGroupId: null,
      selectedFilter: 'الكل',
      searchQuery: '',
      currentFavorites: [],
      stores: [],
      storeGroups: [],
      products: [],
      isLoadingGroups: true,
      isLoadingStores: true,
      isLoadingProducts: true,
    );
  }

  HomeState copyWith({
    String? selectedCategory,
    String? selectedGroupId,
    String? selectedFilter,
    String? searchQuery,
    List<String>? currentFavorites,
    List<StoreEntity>? stores,
    List<StoreGroupEntity>? storeGroups,
    List<ProductEntity>? products,
    bool? isLoadingGroups,
    bool? isLoadingStores,
    bool? isLoadingProducts,
    String? errorMessage,
  }) {
    return HomeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedGroupId: selectedGroupId != null
          ? (selectedGroupId == 'clear' ? null : selectedGroupId)
          : this.selectedGroupId,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentFavorites: currentFavorites ?? this.currentFavorites,
      stores: stores ?? this.stores,
      storeGroups: storeGroups ?? this.storeGroups,
      products: products ?? this.products,
      isLoadingGroups: isLoadingGroups ?? this.isLoadingGroups,
      isLoadingStores: isLoadingStores ?? this.isLoadingStores,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        selectedGroupId,
        selectedFilter,
        searchQuery,
        currentFavorites,
        stores,
        storeGroups,
        products,
        isLoadingGroups,
        isLoadingStores,
        isLoadingProducts,
        errorMessage,
      ];
}
