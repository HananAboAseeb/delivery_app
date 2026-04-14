import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/product_entity.dart';
import '../domain/usecases/get_products_usecase.dart';
import '../domain/usecases/search_products_usecase.dart';

// --- EVENTS ---
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final int page;
  final bool isRefresh;
  const FetchProductsEvent({this.page = 1, this.isRefresh = false});
  @override
  List<Object?> get props => [page, isRefresh];
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

// --- STATES ---
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool hasReachedMax;

  const ProductsLoaded(this.products, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [products, hasReachedMax];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLOC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  int _currentPage = 1;
  final int _pageSize = 20;

  ProductBloc({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
  }) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    if (event.isRefresh) {
      _currentPage = 1;
      emit(ProductLoading());
    } else {
      if (state is ProductsLoaded && (state as ProductsLoaded).hasReachedMax)
        return;
      if (state is! ProductsLoaded) emit(ProductLoading());
    }

    try {
      final page = event.isRefresh ? 1 : _currentPage;
      final newProducts = await getProductsUseCase(
          GetProductsParams(page: page, pageSize: _pageSize));

      if (state is ProductsLoaded && !event.isRefresh) {
        final currentProducts = (state as ProductsLoaded).products;
        emit(ProductsLoaded(
          List.of(currentProducts)..addAll(newProducts),
          hasReachedMax: newProducts.length < _pageSize,
        ));
      } else {
        emit(ProductsLoaded(newProducts,
            hasReachedMax: newProducts.length < _pageSize));
      }

      _currentPage = page + 1;
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products =
          await searchProductsUseCase(SearchProductsParams(query: event.query));
      emit(ProductsLoaded(products,
          hasReachedMax: true)); // Search results don't paginate typically here
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
