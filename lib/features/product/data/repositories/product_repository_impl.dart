import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import 'package:my_store/core/utils/mappers/model_to_entity_mapper.dart';
import 'package:my_store/core/errors/exceptions.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts(int page, int pageSize) async {
    try {
      final models = await remoteDataSource.getProducts(page, pageSize);
      return models.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    try {
      final model = await remoteDataSource.getProductById(id);
      return model.toEntity();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final models = await remoteDataSource.searchProducts(query);
      return models.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw Exception('Search error: ${e.message}');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByStore(String storeId,
      {String? itemGroupId, String? tenantId}) async {
    try {
      final models = await remoteDataSource.getProductsByStore(storeId,
          itemGroupId: itemGroupId, tenantId: tenantId);
      return models.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }
}
