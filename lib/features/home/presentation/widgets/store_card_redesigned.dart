import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/favorites/logic/favorites_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_state.dart';

/// A redesigned store card that displays store info in a list-tile style
/// with an image, name, tags, distance, status, and favorites toggle.
class StoreCardRedesigned extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback onFavoriteToggled;

  const StoreCardRedesigned({
    super.key,
    required this.store,
    required this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String imageUrl = store.imageUrl ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreImage(imageUrl: imageUrl),
                const SizedBox(width: 12),
                Expanded(child: _StoreInfo(store: store, theme: theme)),
                _StoreActions(
                  store: store,
                  theme: theme,
                  onFavoriteToggled: onFavoriteToggled,
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
          _StoreFooter(theme: theme),
        ],
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final String imageUrl;

  const _StoreImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Icon(Icons.storefront, color: Colors.grey.shade400, size: 30),
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  final StoreEntity store;
  final ThemeData theme;

  const _StoreInfo({required this.store, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          store.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'شارع الخمسين جوار سما مول',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StoreTag(
              text: 'توصيل برو',
              icon: Icons.delivery_dining,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            _StoreTag(
              text: 'استلم بنفسك',
              icon: Icons.shopping_bag_outlined,
              color: Colors.black87,
            ),
          ],
        ),
      ],
    );
  }
}

class _StoreActions extends StatelessWidget {
  final StoreEntity store;
  final ThemeData theme;
  final VoidCallback onFavoriteToggled;

  const _StoreActions({
    required this.store,
    required this.theme,
    required this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '10.33 كيلو',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final isFavorite =
                context.read<FavoritesCubit>().isFavorite(store.id);
            return GestureDetector(
              onTap: onFavoriteToggled,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? theme.primaryColor : Colors.grey.shade400,
                size: 24,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StoreFooter extends StatelessWidget {
  final ThemeData theme;

  const _StoreFooter({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'مغلق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(Icons.star, color: theme.primaryColor, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _StoreTag({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
