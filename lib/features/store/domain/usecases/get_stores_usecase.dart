import 'package:my_store/core/usecases/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoresUseCase implements UseCase<List<StoreEntity>, NoParams> {
  final StoreRepository repository;

  GetStoresUseCase(this.repository);

  @override
  Future<List<StoreEntity>> call(NoParams params) async {
    return await repository.getStores();
  }
}
