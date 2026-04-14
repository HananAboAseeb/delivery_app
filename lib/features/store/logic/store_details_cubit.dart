import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../domain/entities/store_entity.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';
import 'package:my_store/features/product/domain/usecases/get_products_by_store_usecase.dart';
import '../data/datasources/store_remote_datasource.dart';

part 'store_details_state.dart';

class StoreDetailsCubit extends Cubit<StoreDetailsState> {
  final GetProductsByStoreUseCase getProductsByStoreUseCase;
  final StoreRemoteDataSource storeRemoteDataSource;

  StoreDetailsCubit({
    required this.getProductsByStoreUseCase,
    required this.storeRemoteDataSource,
  }) : super(StoreDetailsState.initial());

  /// Load store details from a pre-fetched StoreEntity.
  /// Then fetch the REAL categories from API and products.
  Future<void> loadStoreFromEntity(StoreEntity store) async {
    debugPrint(
        '📦 [StoreDetailsCubit] Loading store: ${store.name} (id: ${store.id}, tenantId: ${store.tenantId})');

    emit(state.copyWith(
      store: store,
      isLoadingStore: false,
      isLoadingProducts: true,
      storeError: null,
    ));

    // Fetch REAL categories from API: GET /stores-cache/market/{StoreId}
    try {
      final categories =
          await storeRemoteDataSource.getStoreCategories(store.id);
      final itemGroups = categories
          .map((c) => StoreItemGroupEntity(
                groupId: c.itemUnderSubGroupId,
                groupName: c.itemUnderSubGroupName,
              ))
          .toList();

      debugPrint(
          '✅ [StoreDetailsCubit] Got ${itemGroups.length} categories from API');

      emit(state.copyWith(
        itemGroups: itemGroups,
      ));

      // Auto-select first category and fetch its products
      if (itemGroups.isNotEmpty) {
        await fetchProducts(
          store.id,
          itemGroupId: itemGroups.first.groupId,
          tenantId: store.tenantId,
        );
      } else {
        // No categories → try fetching all products
        await fetchProducts(store.id, tenantId: store.tenantId);
      }
    } catch (e) {
      debugPrint('⚠️ [StoreDetailsCubit] Failed to fetch categories: $e');
      // Still try to fetch products even if categories fail
      await fetchProducts(store.id, tenantId: store.tenantId);
    }
  }

  Future<void> fetchProducts(String storeId,
      {String? itemGroupId, String? tenantId}) async {
    emit(state.copyWith(
      isLoadingProducts: true,
      productsError: null,
      selectedItemGroupId: itemGroupId,
      clearSelectedItemGroupId: itemGroupId == null,
    ));

    try {
      // Use tenantId from the store if not passed directly
      final effectiveTenantId = tenantId ?? state.store?.tenantId;

      final params = GetProductsByStoreParams(
        storeId: storeId,
        itemGroupId: itemGroupId,
        tenantId: effectiveTenantId,
      );
      debugPrint(
          '🔄 [StoreDetailsCubit] Fetching products: store=$storeId, group=$itemGroupId, tenant=$effectiveTenantId');
      final products = await getProductsByStoreUseCase(params);
      debugPrint('✅ [StoreDetailsCubit] Got ${products.length} products');

      emit(state.copyWith(
        products: products,
        isLoadingProducts: false,
      ));
    } catch (e) {
      debugPrint('❌ [StoreDetailsCubit] Failed to fetch products: $e');
      emit(state.copyWith(
        isLoadingProducts: false,
        products: [],
        productsError: e.toString(),
      ));
    }
  }

  void selectTab(String storeId, String? itemGroupId) {
    if (state.selectedItemGroupId == itemGroupId) return;
    fetchProducts(storeId, itemGroupId: itemGroupId);
  }
}
