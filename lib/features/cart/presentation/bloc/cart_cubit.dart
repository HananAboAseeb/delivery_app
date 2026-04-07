import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'package:my_store/core/usecases/usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';

// --- STATES ---
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  const CartLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- CUBIT ---
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase updateQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartCubit({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateQuantityUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    try {
      final items = await getCartUseCase(NoParams());
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addItem(CartItemEntity item) async {
    try {
      await addToCartUseCase(AddToCartParams(item: item));
      await loadCart(); // Refresh cart
    } catch (e) {
      emit(CartError(e.toString()));
      await loadCart();
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await removeFromCartUseCase(RemoveFromCartParams(itemId: itemId));
      await loadCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await updateQuantityUseCase(UpdateCartItemQuantityParams(itemId: itemId, quantity: quantity));
      await loadCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> clearCart() async {
    try {
      await clearCartUseCase(NoParams());
      emit(const CartLoaded([]));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
