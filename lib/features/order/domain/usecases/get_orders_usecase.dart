import 'package:my_store/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import 'package:equatable/equatable.dart';

class GetOrdersUseCase implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(GetOrdersParams params) async {
    return await repository.getOrders(status: params.status, date: params.date);
  }
}

class GetOrdersParams extends Equatable {
  final String? status;
  final DateTime? date;

  const GetOrdersParams({this.status, this.date});

  @override
  List<Object?> get props => [status, date];
}
