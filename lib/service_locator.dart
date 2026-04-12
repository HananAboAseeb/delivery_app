import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Store UseCases
import 'features/store/domain/usecases/get_store_groups_usecase.dart';
import 'features/store/domain/usecases/get_stores_by_group_usecase.dart';
import 'features/store/domain/usecases/get_stores_usecase.dart';

// HomeCubit
import 'features/home/presentation/cubit/home_cubit.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/signalr_service.dart';
import 'core/database/database.dart';
import 'core/theme/theme_cubit.dart';

// --- DATA LAYER ---
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/local/user_local_datasource.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/cart/data/datasources/local/cart_local_datasource.dart';
import 'features/order/data/datasources/order_remote_datasource.dart';
import 'features/order/data/datasources/local/orders_local_datasource.dart';
import 'features/store/data/datasources/store_remote_datasource.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/store/data/repositories/store_repository_impl.dart';

// --- DOMAIN LAYER ---
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/order/domain/repositories/order_repository.dart';
import 'features/store/domain/repositories/store_repository.dart';

import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';

import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/search_products_usecase.dart';
import 'features/product/domain/usecases/get_products_by_store_usecase.dart';

import 'features/cart/domain/usecases/get_cart_usecase.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'features/cart/domain/usecases/clear_cart_usecase.dart';

import 'features/order/domain/usecases/create_order_usecase.dart';
import 'features/order/domain/usecases/get_orders_usecase.dart';

// --- PRESENTATION LAYER ---
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/presentation/bloc/cart_cubit.dart';
import 'features/order/presentation/bloc/order_bloc.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> setupServiceLocator() async {
  // 1. Core Services (Singletons)
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<SignalRService>(() => SignalRService());
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // 2. Data Sources (Lazy Singletons)
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(database: sl()));
  // Product
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(apiClient: sl()));
  // Cart
  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(database: sl()));
  // Order
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<OrdersLocalDataSource>(() => OrdersLocalDataSourceImpl(database: sl()));
  // Store
  sl.registerLazySingleton<StoreRemoteDataSource>(() => StoreRemoteDataSourceImpl(apiClient: sl()));

  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(remoteDataSource: sl()));

  // 4. UseCases (Lazy Singletons)
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByStoreUseCase(sl()));

  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantityUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));

  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));

  // Store UseCases
  sl.registerLazySingleton(() => GetStoreGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetStoresByGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetStoresUseCase(sl()));

  // 5. BLoCs / Cubits (Factories)
  sl.registerFactory(() => ThemeCubit(sl()));
  
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  sl.registerFactory(() => ProductBloc(
        getProductsUseCase: sl(),
        searchProductsUseCase: sl(),
      ));

  sl.registerFactory(() => CartCubit(
        getCartUseCase: sl(),
        addToCartUseCase: sl(),
        removeFromCartUseCase: sl(),
        updateQuantityUseCase: sl(),
        clearCartUseCase: sl(),
      ));

  sl.registerFactory(() => OrderBloc(
        createOrderUseCase: sl(),
        getOrdersUseCase: sl(),
      ));

  sl.registerFactory(() => HomeCubit(
        getStoreGroupsUseCase: sl(),
        getStoresByGroupUseCase: sl(),
        getStoresUseCase: sl(),
        productRepository: sl(),
      ));
}
