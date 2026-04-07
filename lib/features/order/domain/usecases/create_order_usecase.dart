import 'package:my_store/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import 'package:equatable/equatable.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<OrderEntity> call(CreateOrderParams params) async {
    return await repository.createOrder(params.order);
  }
}

class CreateOrderParams extends Equatable {
  final OrderEntity order;

  const CreateOrderParams({required this.order});

  @override
  List<Object?> get props => [order];
}
