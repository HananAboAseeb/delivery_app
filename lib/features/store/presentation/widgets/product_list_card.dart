import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_store/features/store/domain/entities/store_entity.dart';




import 'package:my_store/features/favorites/logic/favorites_cubit.dart';
import 'package:my_store/features/favorites/logic/favorites_state.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';

/// A card displaying product info, formatting, and add-to-cart actions.
class ProductListCard extends StatelessWidget {
  final ProductEntity product;
  final StoreEntity store;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const ProductListCard({
    super.key,
    required this.product,
    required this.store,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String imageUrl = product.imageUrl ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop';
    final isOption =
        product.name.contains('نصف') || product.name.contains('ربع');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // RIGHT SIDE: Image + Favorite icon (RTL visually)
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favState) {
                    final isFav = context
                        .read<FavoritesCubit>()
                        .isFavorite(product.id.toString());
                    return GestureDetector(
                      onTap: () {
                        context.read<FavoritesCubit>().toggleFavorite(
                              product.id.toString(),
                              product.name,
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // MIDDLE: Name
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // LEFT SIDE: Price and Action Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    product.unitPrice.toStringAsFixed(0),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 2),
                  const Text('ريال',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              if (!isOption) ...[
                const SizedBox(height: 8),
                // Quantity Selector
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (quantity > 1) onQuantityChanged(quantity - 1);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.remove,
                              size: 14, color: Colors.black54),
                        ),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      InkWell(
                        onTap: () => onQuantityChanged(quantity + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.add,
                              size: 14, color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                width: 100,
                child: ElevatedButton(
                  onPressed: isOption ? () {} : onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isOption ? Colors.orange.shade400 : theme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    isOption ? 'عرض الخيارات' : 'أضف للسلة',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
