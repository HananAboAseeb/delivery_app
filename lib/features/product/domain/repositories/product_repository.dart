import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts(int page, int pageSize);
  Future<ProductEntity> getProductById(String id);
  Future<List<ProductEntity>> searchProducts(String query);
  Future<List<ProductEntity>> getProductsByStore(String storeId,
      {String? itemGroupId, String? tenantId});
}
