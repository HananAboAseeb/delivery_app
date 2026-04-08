import 'package:my_store/core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

class GetProductsByStoreUseCase implements UseCase<List<ProductEntity>, GetProductsByStoreParams> {
  final ProductRepository repository;

  GetProductsByStoreUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(GetProductsByStoreParams params) async {
    return await repository.getProductsByStore(params.storeId, itemGroupId: params.itemGroupId);
  }
}

class GetProductsByStoreParams extends Equatable {
  final String storeId;
  final String? itemGroupId;

  const GetProductsByStoreParams({required this.storeId, this.itemGroupId});

  @override
  List<Object?> get props => [storeId, itemGroupId];
}
