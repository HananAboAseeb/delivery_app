import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/domain/usecases/get_store_groups_usecase.dart';
import 'package:my_store/features/store/domain/usecases/get_stores_by_group_usecase.dart';
import 'package:my_store/features/store/domain/usecases/get_stores_usecase.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';
import 'package:my_store/features/product/domain/repositories/product_repository.dart';

import 'package:my_store/core/usecases/usecase.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetStoreGroupsUseCase getStoreGroupsUseCase;
  final GetStoresByGroupUseCase getStoresByGroupUseCase;
  final GetStoresUseCase getStoresUseCase;
  final ProductRepository? productRepository;

  HomeCubit({
    required this.getStoreGroupsUseCase,
    required this.getStoresByGroupUseCase,
    required this.getStoresUseCase,
    this.productRepository,
  }) : super(HomeState.initial());

  List<StoreEntity> _allLoadedStoresCache = [];
  List<ProductEntity> _allLoadedProductsCache = [];

  Future<void> fetchStoreGroups() async {
    emit(state.copyWith(isLoadingGroups: true, errorMessage: null));
    try {
      debugPrint('📦 [HomeCubit] Fetching store groups...');
      final groups = await getStoreGroupsUseCase();
      debugPrint('✅ [HomeCubit] Got ${groups.length} store groups');
      for (final g in groups) {
        debugPrint('   → Group: ${g.name} (id: ${g.id})');
      }
      // Sort so 'مطاعم' is always first
      groups.sort((a, b) {
        if ((a.name ?? '').contains('مطاعم')) return -1;
        if ((b.name ?? '').contains('مطاعم')) return 1;
        return 0; // maintain original order for others
      });

      emit(state.copyWith(
        storeGroups: groups,
        isLoadingGroups: false,
      ));
    } catch (e) {
      debugPrint('❌ [HomeCubit] Failed to fetch store groups: $e');
      emit(state.copyWith(
        isLoadingGroups: false,
        errorMessage: 'فشل في جلب الفئات: $e',
      ));
    }
  }

  Future<void> fetchStores({String? groupId}) async {
    // ══════════════════════════════════════════════════════════════════
    // FIX #3: Clear the old stores immediately when switching categories
    // This prevents showing stale data from the previous category.
    // ══════════════════════════════════════════════════════════════════
    _allLoadedStoresCache = [];
    emit(state.copyWith(
      isLoadingStores: true,
      stores: [], // Clear displayed stores immediately
      errorMessage: null,
    ));

    try {
      List<StoreEntity> stores;
      if (groupId != null && groupId != 'clear') {
        debugPrint('📦 [HomeCubit] Fetching stores for group: $groupId');
        stores = await getStoresByGroupUseCase(groupId);
      } else {
        debugPrint('📦 [HomeCubit] Fetching all stores...');
        stores = await getStoresUseCase(NoParams());
      }

      debugPrint('✅ [HomeCubit] Got ${stores.length} stores');
      _allLoadedStoresCache = stores;

      emit(state.copyWith(isLoadingStores: false));
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('❌ [HomeCubit] Failed to fetch stores: $e');
      // ══════════════════════════════════════════════════════════════
      // FIX #3 continued: On error, keep the cache empty so the UI
      // shows the empty state rather than old data from another category.
      // ══════════════════════════════════════════════════════════════
      _allLoadedStoresCache = [];
      emit(state.copyWith(
        isLoadingStores: false,
        stores: [], // Ensure empty list is emitted
      ));
      _applyFiltersAndSort();
    }
  }

  Future<void> fetchProducts() async {
    if (productRepository == null) {
      debugPrint('⚠️ [HomeCubit] No productRepository provided');
      return;
    }
    emit(state.copyWith(isLoadingProducts: true));
    try {
      debugPrint('📦 [HomeCubit] Fetching products...');
      final products = await productRepository!.getProducts(1, 50);
      debugPrint('✅ [HomeCubit] Got ${products.length} products');
      for (final p in products.take(3)) {
        debugPrint(
            '   → Product: ${p.name} - ${p.unitPrice} ${p.currencyName}');
      }
      _allLoadedProductsCache = products;
      emit(state.copyWith(
        products: products,
        isLoadingProducts: false,
      ));
    } catch (e) {
      debugPrint('❌ [HomeCubit] Failed to fetch products: $e');
      emit(state.copyWith(
        isLoadingProducts: false,
        errorMessage: 'فشل في جلب المنتجات: $e',
      ));
    }
  }

  void _applyFiltersAndSort({
    String? category,
    String? categoryId,
    String? filter,
    String? searchQuery,
    List<String>? currentFavorites,
  }) {
    final cat = category ?? state.selectedCategory;
    final catId = categoryId ?? state.selectedGroupId;
    final filt = filter ?? state.selectedFilter;
    final q = searchQuery ?? state.searchQuery;
    final favs = currentFavorites ?? state.currentFavorites;

    List<StoreEntity> filteredList = List.from(_allLoadedStoresCache);

    // Text search filtering
    if (q.trim().isNotEmpty) {
      filteredList =
          filteredList.where((store) => store.name.contains(q.trim())).toList();
    }

    // Filter by tab
    switch (filt) {
      case 'الأقرب':
        break;
      case 'الجديدة':
        filteredList.shuffle();
        break;
      case 'المفضلة':
        filteredList =
            filteredList.where((store) => favs.contains(store.id)).toList();
        break;
      case 'الكل':
      default:
        break;
    }

    // Also filter products by search if applicable
    List<ProductEntity> filteredProducts = List.from(_allLoadedProductsCache);
    if (q.trim().isNotEmpty) {
      filteredProducts =
          filteredProducts.where((p) => p.name.contains(q.trim())).toList();
    }

    emit(state.copyWith(
      selectedCategory: cat,
      selectedGroupId: catId,
      selectedFilter: filt,
      searchQuery: q,
      currentFavorites: favs,
      stores: filteredList,
      products: filteredProducts,
    ));
  }

  void selectCategory(String categoryName, String? categoryId) {
    if (state.selectedCategory == categoryName) {
      // Deselect — go back to "all"
      fetchStores(groupId: null);
      _applyFiltersAndSort(category: 'الكل', categoryId: 'clear');
    } else {
      // Select new category — fetch its stores
      _applyFiltersAndSort(category: categoryName, categoryId: categoryId);
      fetchStores(groupId: categoryId);
    }
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

  Future<void> loadInitialData(List<String> initialFavs) async {
    _applyFiltersAndSort(
        category: 'الكل',
        categoryId: 'clear',
        filter: 'الكل',
        searchQuery: '',
        currentFavorites: initialFavs);

    // Fetch groups first
    await fetchStoreGroups();

    // ══════════════════════════════════════════════════════════════════
    // FIX #2: Auto-select the first category (المطاعم or whatever is first)
    // so the user sees relevant stores immediately instead of random data.
    // ══════════════════════════════════════════════════════════════════
    if (state.storeGroups.isNotEmpty) {
      // Prefer "المطاعم" if it exists, otherwise pick first group
      final restaurantGroup = state.storeGroups.firstWhere(
        (g) => (g.name ?? '').contains('مطاعم'),
        orElse: () => state.storeGroups.first,
      );

      debugPrint(
          '🎯 [HomeCubit] Auto-selecting default group: ${restaurantGroup.name}');

      _applyFiltersAndSort(
        category: restaurantGroup.name ?? 'الكل',
        categoryId: restaurantGroup.id,
      );

      // Fetch stores for the auto-selected group + products in parallel
      await Future.wait([
        fetchStores(groupId: restaurantGroup.id),
        fetchProducts(),
      ]);
    } else {
      // No groups available — just fetch whatever we can
      await Future.wait([
        fetchStores(),
        fetchProducts(),
      ]);
    }

    debugPrint(
        '🏠 [HomeCubit] Initial data loaded → stores: ${_allLoadedStoresCache.length}, products: ${_allLoadedProductsCache.length}');
  }
}
