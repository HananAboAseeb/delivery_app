import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_store/features/splash/presentation/pages/splash_page.dart';
import 'package:my_store/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:my_store/features/auth/presentation/pages/login_page.dart';
import 'package:my_store/features/auth/presentation/pages/register_page.dart';
import 'package:my_store/features/home/presentation/pages/home_page.dart';
import 'package:my_store/features/store/presentation/pages/store_details_page.dart';
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/cart/presentation/pages/cart_page.dart';
import 'package:my_store/features/order/presentation/pages/orders_page.dart';
import 'package:my_store/features/profile/presentation/pages/profile_page.dart';
import 'package:my_store/features/search/presentation/pages/search_page.dart';
import 'package:my_store/features/address/presentation/pages/address_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/store-details',
      builder: (context, state) {
        final store = state.extra as StoreEntity;
        return StoreDetailsPage(store: store);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/address',
      builder: (context, state) => const AddressPage(),
    ),
  ],
);
