import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoreGroupsUseCase {
  final StoreRepository repository;

  GetStoreGroupsUseCase(this.repository);

  Future<List<StoreGroupEntity>> call() async {
    return await repository.getStoreGroups();
  }
}
