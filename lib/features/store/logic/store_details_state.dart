part of 'store_details_cubit.dart';

class StoreDetailsState extends Equatable {
  final StoreEntity? store;
  final bool isLoadingStore;
  final String? storeError;

  final List<StoreItemGroupEntity> itemGroups;
  final String? selectedItemGroupId;

  final List<ProductEntity> products;
  final bool isLoadingProducts;
  final String? productsError;

  const StoreDetailsState({
    this.store,
    this.isLoadingStore = false,
    this.storeError,
    this.itemGroups = const [],
    this.selectedItemGroupId,
    this.products = const [],
    this.isLoadingProducts = false,
    this.productsError,
  });

  factory StoreDetailsState.initial() => const StoreDetailsState();

  StoreDetailsState copyWith({
    StoreEntity? store,
    bool? isLoadingStore,
    String? storeError,
    List<StoreItemGroupEntity>? itemGroups,
    String? selectedItemGroupId,
    List<ProductEntity>? products,
    bool? isLoadingProducts,
    String? productsError,
    bool clearSelectedItemGroupId = false,
  }) {
    return StoreDetailsState(
      store: store ?? this.store,
      isLoadingStore: isLoadingStore ?? this.isLoadingStore,
      storeError: storeError ?? this.storeError,
      itemGroups: itemGroups ?? this.itemGroups,
      selectedItemGroupId: clearSelectedItemGroupId
          ? null
          : (selectedItemGroupId ?? this.selectedItemGroupId),
      products: products ?? this.products,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      productsError: productsError ?? this.productsError,
    );
  }

  @override
  List<Object?> get props => [
        store,
        isLoadingStore,
        storeError,
        itemGroups,
        selectedItemGroupId,
        products,
        isLoadingProducts,
        productsError,
      ];
}
