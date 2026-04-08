import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoresByGroupUseCase {
  final StoreRepository repository;

  GetStoresByGroupUseCase(this.repository);

  Future<List<StoreEntity>> call(String groupId) async {
    return await repository.getStoresByGroup(groupId);
  }
}
