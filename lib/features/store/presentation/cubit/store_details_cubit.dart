import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/get_store_by_id_usecase.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/usecases/get_products_by_store_usecase.dart';

part 'store_details_state.dart';

class StoreDetailsCubit extends Cubit<StoreDetailsState> {
  final GetStoreByIdUseCase getStoreByIdUseCase;
  final GetProductsByStoreUseCase getProductsByStoreUseCase;

  StoreDetailsCubit({
    required this.getStoreByIdUseCase,
    required this.getProductsByStoreUseCase,
  }) : super(StoreDetailsState.initial());

  Future<void> loadStoreDetails(String storeId) async {
    emit(state.copyWith(isLoadingStore: true, storeError: null));

    try {
      final store = await getStoreByIdUseCase(GetStoreByIdParams(id: storeId));
      final itemGroups = store.storesItemGroups;

      emit(state.copyWith(
        store: store,
        itemGroups: itemGroups,
        isLoadingStore: false,
      ));

      // After fetching store, fetch products
      await fetchProducts(storeId);
    } catch (e) {
      emit(state.copyWith(
        isLoadingStore: false,
        storeError: e.toString(),
      ));
    }
  }

  Future<void> fetchProducts(String storeId, {String? itemGroupId}) async {
    emit(state.copyWith(
      isLoadingProducts: true,
      productsError: null,
      selectedItemGroupId: itemGroupId,
      clearSelectedItemGroupId: itemGroupId == null,
    ));

    try {
      final params = GetProductsByStoreParams(
        storeId: storeId,
        itemGroupId: itemGroupId,
      );
      final products = await getProductsByStoreUseCase(params);
      
      emit(state.copyWith(
        products: products,
        isLoadingProducts: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingProducts: false,
        productsError: e.toString(),
      ));
    }
  }

  void selectTab(String storeId, String? itemGroupId) {
    if (state.selectedItemGroupId == itemGroupId) return;
    fetchProducts(storeId, itemGroupId: itemGroupId);
  }
}
