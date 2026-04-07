import 'package:my_store/core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

class SearchProductsUseCase implements UseCase<List<ProductEntity>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams extends Equatable {
  final String query;

  const SearchProductsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
