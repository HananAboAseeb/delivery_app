import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';
import 'package:my_store/core/utils/mappers/model_to_entity_mapper.dart';
import 'package:my_store/core/errors/exceptions.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StoreEntity>> getStores() async {
    try {
      final models = await remoteDataSource.getStores();
      return models.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }

  @override
  Future<StoreEntity> getStoreById(String id) async {
    try {
      final model = await remoteDataSource.getStoreById(id);
      return model.toEntity();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }

  @override
  Future<List<StoreEntity>> getStoresByRegion(String regionId) async {
    try {
      final models = await remoteDataSource.getStoresByRegion(regionId);
      return models.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    }
  }
}
