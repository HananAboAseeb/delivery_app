import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../features/store/domain/entities/store_entity.dart';
import '../../../../features/store/domain/usecases/get_store_groups_usecase.dart';
import '../../../../features/store/domain/usecases/get_stores_by_group_usecase.dart';
import '../../../../features/store/domain/usecases/get_stores_usecase.dart';
import '../../../../features/product/domain/entities/product_entity.dart';
import '../../../../features/product/domain/repositories/product_repository.dart';

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
    emit(state.copyWith(isLoadingStores: true, errorMessage: null));
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
      emit(state.copyWith(
        isLoadingStores: false,
        // Don't set error for stores - we'll fall back to products
      ));
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
        debugPrint('   → Product: ${p.name} - ${p.unitPrice} ${p.currencyName}');
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
      filteredList = filteredList.where((store) => store.name.contains(q.trim())).toList();
    }

    // Filter by tab
    switch (filt) {
      case 'الأقرب':
        break;
      case 'الجديدة':
        filteredList.shuffle();
        break;
      case 'المفضلة':
        filteredList = filteredList.where((store) => favs.contains(store.name)).toList();
        break;
      case 'الكل':
      default:
        break;
    }

    // Also filter products by search if applicable
    List<ProductEntity> filteredProducts = List.from(_allLoadedProductsCache);
    if (q.trim().isNotEmpty) {
      filteredProducts = filteredProducts.where((p) => p.name.contains(q.trim())).toList();
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
      fetchStores(groupId: null);
      _applyFiltersAndSort(category: 'الكل', categoryId: 'clear');
    } else {
      fetchStores(groupId: categoryId);
      _applyFiltersAndSort(category: categoryName, categoryId: categoryId);
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
    _applyFiltersAndSort(category: 'الكل', categoryId: 'clear', filter: 'الكل', searchQuery: '', currentFavorites: initialFavs);
    
    // Fetch groups first, then stores and products in parallel
    await fetchStoreGroups();
    
    // Fetch stores and products in parallel for better performance
    await Future.wait([
      fetchStores(),
      fetchProducts(),
    ]);
    
    debugPrint('🏠 [HomeCubit] Initial data loaded → stores: ${_allLoadedStoresCache.length}, products: ${_allLoadedProductsCache.length}');
  }
}
