import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/home/logic/home_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_state.dart';

import 'package:my_store/features/home/presentation/widgets/home_app_bar.dart';
import 'package:my_store/features/home/presentation/widgets/home_categories_section.dart';
import 'package:my_store/features/home/presentation/widgets/home_filter_row.dart';
import 'package:my_store/features/home/presentation/widgets/home_stores_section.dart';
import 'package:my_store/features/home/presentation/widgets/offers_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = di.sl<HomeCubit>();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        _homeCubit.syncFavorites(state.favoriteStoreIds.toList());
      },
      child: BlocProvider<HomeCubit>.value(
        value: _homeCubit,
        child: const Scaffold(
          backgroundColor: Color(0xFFFAFAFA),
          body: _HomeBody(),
        ),
      ),
    );
  }
}

/// The scrollable body of the home screen, composed entirely of
/// self-contained widgets — each managing its own slice of state.
class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favs =
          context.read<FavoritesCubit>().state.favoriteStoreIds.toList();
      context.read<HomeCubit>().loadInitialData(favs);
    });
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        HomeAppBar(searchFocusNode: _searchFocusNode),
        const SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OperationalHoursBanner(),
              SizedBox(height: 12),
              HomeCategoriesSection(),
              SizedBox(height: 16),
              OffersSlider(),
              SizedBox(height: 20),
              HomeFilterRow(),
              SizedBox(height: 20),
            ],
          ),
        ),
        const HomeStoresSection(),
      ],
    );
  }
}

/// A simple informational banner showing operational hours.
class _OperationalHoursBanner extends StatelessWidget {
  const _OperationalHoursBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_filled,
              color: Colors.orange.shade400, size: 16),
          const SizedBox(width: 6),
          const Text(
            'أوقات الدوام من 7:30 الصباح وحتى 11 المساء',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
