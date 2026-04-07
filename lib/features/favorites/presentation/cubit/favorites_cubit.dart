import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FlutterSecureStorage _storage;
  static const String _favKey = 'FAVORITES_DATA';

  FavoritesCubit(this._storage) : super(FavoritesInitial()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final dataStr = await _storage.read(key: _favKey);
      
      if (dataStr == null || dataStr.isEmpty) {
        emit(const FavoritesLoaded(favoriteStoreIds: {}, favoriteStoreNames: {}));
        return;
      }

      // Format expected: "id1|name1,id2|name2"
      final items = dataStr.split(',');
      
      final Set<String> ids = {};
      final Set<String> names = {};

      for (var item in items) {
        if (item.contains('|')) {
          final parts = item.split('|');
          if (parts.length == 2) {
            ids.add(parts[0]);
            names.add(parts[1]);
          }
        }
      }

      emit(FavoritesLoaded(
        favoriteStoreIds: ids,
        favoriteStoreNames: names,
      ));
    } catch (_) {
      emit(const FavoritesLoaded(favoriteStoreIds: {}, favoriteStoreNames: {}));
    }
  }

  Future<void> toggleFavorite(String storeId, String storeName) async {
    Map<String, String> currentFavs = {};
    
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final ids = currentState.favoriteStoreIds.toList();
      final names = currentState.favoriteStoreNames.toList();
      for (int i = 0; i < ids.length; i++) {
        if (i < names.length) {
          currentFavs[ids[i]] = names[i];
        }
      }
    }

    if (currentFavs.containsKey(storeId)) {
      currentFavs.remove(storeId);
    } else {
      currentFavs[storeId] = storeName;
    }

    // Build the string back as expected: "id1|name1,id2|name2"
    final List<String> combined = currentFavs.entries.map((e) => '${e.key}|${e.value}').toList();
    final newDataStr = combined.join(',');

    try {
      await _storage.write(key: _favKey, value: newDataStr);
    } catch (_) {}

    emit(FavoritesLoaded(
      favoriteStoreIds: currentFavs.keys.toSet(),
      favoriteStoreNames: currentFavs.values.toSet(),
    ));
  }

  bool isFavorite(String storeId) {
    if (state is FavoritesLoaded) {
      return (state as FavoritesLoaded).isFavorite(storeId);
    }
    return false;
  }
}
