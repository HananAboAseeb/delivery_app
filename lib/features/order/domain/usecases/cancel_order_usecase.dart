import 'package:my_store/core/usecases/usecase.dart';
import '../repositories/order_repository.dart';
import 'package:equatable/equatable.dart';

class CancelOrderUseCase implements UseCase<void, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<void> call(CancelOrderParams params) async {
    return await repository.cancelOrder(params.id);
  }
}

class CancelOrderParams extends Equatable {
  final String id;

  const CancelOrderParams({required this.id});

  @override
  List<Object?> get props => [id];
}
