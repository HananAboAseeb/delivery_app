import 'package:my_store/core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

class GetProductsUseCase implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(GetProductsParams params) async {
    return await repository.getProducts(params.page, params.pageSize);
  }
}

class GetProductsParams extends Equatable {
  final int page;
  final int pageSize;

  const GetProductsParams({required this.page, required this.pageSize});

  @override
  List<Object?> get props => [page, pageSize];
}
