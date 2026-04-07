import 'package:my_store/core/usecases/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';
import 'package:equatable/equatable.dart';

class GetStoreByIdUseCase implements UseCase<StoreEntity, GetStoreByIdParams> {
  final StoreRepository repository;

  GetStoreByIdUseCase(this.repository);

  @override
  Future<StoreEntity> call(GetStoreByIdParams params) async {
    return await repository.getStoreById(params.id);
  }
}

class GetStoreByIdParams extends Equatable {
  final String id;

  const GetStoreByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
