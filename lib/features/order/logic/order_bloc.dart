import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/order_entity.dart';
import '../domain/usecases/create_order_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';

// --- EVENTS ---
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final OrderEntity order;
  const CreateOrderEvent(this.order);
  @override
  List<Object?> get props => [order];
}

class FetchOrdersEvent extends OrderEvent {}

// --- STATES ---
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderCreated extends OrderState {
  final OrderEntity order;
  const OrderCreated(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLOC ---
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;

  OrderBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
  }) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<FetchOrdersEvent>(_onFetchOrders);
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final newOrder =
          await createOrderUseCase(CreateOrderParams(order: event.order));
      emit(OrderCreated(newOrder));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrders(
      FetchOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await getOrdersUseCase(const GetOrdersParams());
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
