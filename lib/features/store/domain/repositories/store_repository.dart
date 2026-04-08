import '../entities/store_entity.dart';

abstract class StoreRepository {
  Future<List<StoreEntity>> getStores();
  Future<StoreEntity> getStoreById(String id);
  Future<List<StoreEntity>> getStoresByRegion(String regionId);
  Future<List<StoreGroupEntity>> getStoreGroups();
  Future<List<StoreEntity>> getStoresByGroup(String groupId);
}
