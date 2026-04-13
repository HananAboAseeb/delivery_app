import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'service_locator.dart' as di;

import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/presentation/bloc/cart_cubit.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Fix for Image.network failing to load SSL images
  HttpOverrides.global = MyHttpOverrides();
  
  // 1. Initialize Dependency Injection
  await di.setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ProductBloc>()),
        BlocProvider(create: (_) => di.sl<CartCubit>()),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
        BlocProvider(create: (_) => FavoritesCubit(di.sl<FlutterSecureStorage>())),
        BlocProvider(create: (_) => ProfileCubit(di.sl<FlutterSecureStorage>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          // ALWAYS load default theme during development to ensure hot-reload fetches config instantly
          return MaterialApp.router(
            title: ThemeConfig.defaultTheme().appName,
            theme: AppTheme.buildTheme(ThemeConfig.defaultTheme()),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
            },
          );
        },
      ),
    );
  }
}
