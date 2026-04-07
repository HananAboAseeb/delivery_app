import 'package:my_store/core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<void, NoParams> {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.clearCart();
  }
}
