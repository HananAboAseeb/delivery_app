import 'package:my_store/core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateCartItemQuantityUseCase
    implements UseCase<void, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  @override
  Future<void> call(UpdateCartItemQuantityParams params) async {
    return await repository.updateQuantity(params.itemId, params.quantity);
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantityParams(
      {required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}
