import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/home/logic/home_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_cubit.dart';
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/presentation/pages/store_details_page.dart';
import 'package:my_store/features/home/presentation/widgets/store_card_redesigned.dart';

/// The stores sliver list section — handles loading, error, empty,
/// and populated states, and navigates to StoreDetailsPage on tap.
class HomeStoresSection extends StatelessWidget {
  const HomeStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) =>
          prev.isLoadingStores != curr.isLoadingStores ||
          prev.stores != curr.stores ||
          prev.errorMessage != curr.errorMessage,
      builder: (context, state) {
        if (state.isLoadingStores) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.errorMessage != null) {
          return SliverFillRemaining(
            child: _StoresErrorView(
              onRetry: () => context
                  .read<HomeCubit>()
                  .fetchStores(groupId: state.selectedGroupId),
            ),
          );
        }

        if (state.stores.isEmpty) {
          return const SliverFillRemaining(child: _StoresEmptyView());
        }

        return SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _StoreListItem(store: state.stores[index]),
              childCount: state.stores.length,
            ),
          ),
        );
      },
    );
  }
}

/// A single list item wrapping the StoreCardRedesigned with navigation.
class _StoreListItem extends StatelessWidget {
  final StoreEntity store;

  const _StoreListItem({required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreDetailsPage(store: store)),
        );
      },
      child: StoreCardRedesigned(
        store: store,
        onFavoriteToggled: () {
          context.read<FavoritesCubit>().toggleFavorite(store.id, store.name);
        },
      ),
    );
  }
}

class _StoresErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _StoresErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل المتاجر',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _StoresEmptyView extends StatelessWidget {
  const _StoresEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
