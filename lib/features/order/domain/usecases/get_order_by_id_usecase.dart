import 'package:my_store/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import 'package:equatable/equatable.dart';

class GetOrderByIdUseCase implements UseCase<OrderEntity, GetOrderByIdParams> {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<OrderEntity> call(GetOrderByIdParams params) async {
    return await repository.getOrderById(params.id);
  }
}

class GetOrderByIdParams extends Equatable {
  final String id;

  const GetOrderByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
