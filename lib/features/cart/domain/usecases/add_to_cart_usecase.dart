import 'package:my_store/core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';
import 'package:equatable/equatable.dart';

class AddToCartUseCase implements UseCase<void, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<void> call(AddToCartParams params) async {
    return await repository.addToCart(params.item);
  }
}

class AddToCartParams extends Equatable {
  final CartItemEntity item;

  const AddToCartParams({required this.item});

  @override
  List<Object?> get props => [item];
}
