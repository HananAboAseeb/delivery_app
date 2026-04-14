import 'package:my_store/core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

class GetProductByIdUseCase
    implements UseCase<ProductEntity, GetProductByIdParams> {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<ProductEntity> call(GetProductByIdParams params) async {
    return await repository.getProductById(params.id);
  }
}

class GetProductByIdParams extends Equatable {
  final String id;

  const GetProductByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
