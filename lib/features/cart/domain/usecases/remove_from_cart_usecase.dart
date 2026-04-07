import 'package:my_store/core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';
import 'package:equatable/equatable.dart';

class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<void> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(params.itemId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String itemId;

  const RemoveFromCartParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
