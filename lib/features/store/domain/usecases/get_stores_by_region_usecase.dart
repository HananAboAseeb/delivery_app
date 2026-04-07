import 'package:my_store/core/usecases/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';
import 'package:equatable/equatable.dart';

class GetStoresByRegionUseCase implements UseCase<List<StoreEntity>, GetStoresByRegionParams> {
  final StoreRepository repository;

  GetStoresByRegionUseCase(this.repository);

  @override
  Future<List<StoreEntity>> call(GetStoresByRegionParams params) async {
    return await repository.getStoresByRegion(params.regionId);
  }
}

class GetStoresByRegionParams extends Equatable {
  final String regionId;

  const GetStoresByRegionParams({required this.regionId});

  @override
  List<Object?> get props => [regionId];
}
