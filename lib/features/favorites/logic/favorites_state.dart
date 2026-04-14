import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  Set<String> get favoriteStoreIds => {};
  Set<String> get favoriteStoreNames => {};
  bool isFavorite(String storeId) => false;
  bool isFavoriteName(String storeName) => false;

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteStoreIds;
  final Set<String> favoriteStoreNames;

  const FavoritesLoaded({
    required this.favoriteStoreIds,
    required this.favoriteStoreNames,
  });

  bool isFavorite(String storeId) {
    return favoriteStoreIds.contains(storeId);
  }

  bool isFavoriteName(String storeName) {
    return favoriteStoreNames.contains(storeName);
  }

  @override
  List<Object> get props => [favoriteStoreIds, favoriteStoreNames];
}
