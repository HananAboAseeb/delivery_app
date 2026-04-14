import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/favorites/logic/favorites_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_state.dart';

/// The hero app bar for the store details showing header, rating, delivery type.
class StoreHeroAppBar extends StatelessWidget {
  final StoreEntity store;

  const StoreHeroAppBar({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        store.name,
        style: const TextStyle(
            fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () {},
        ),
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final isFav = context.read<FavoritesCubit>().isFavorite(store.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () {
                context
                    .read<FavoritesCubit>()
                    .toggleFavorite(store.id, store.name);
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 40.0, left: 16, right: 16, bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _RatingInfoRow(),
                const SizedBox(height: 12),
                _DeliveryTypeRow(),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingInfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('الأسعار مطابقة للمطعم',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          Container(width: 1, height: 16, color: Colors.white.withOpacity(0.5)),
          Row(
            children: List.generate(
                5,
                (index) =>
                    const Icon(Icons.star, color: Colors.white, size: 14)),
          ),
          const Column(
            children: [
              Text('التقييمات',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              Text('( 2249 )',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

class _DeliveryTypeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('استلم بنفسك',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade500,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text('توصيل',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
