import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/data/datasources/store_remote_datasource.dart';
import 'package:my_store/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';
import 'package:my_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_store/features/cart/presentation/bloc/cart_cubit.dart';
import '../cubit/store_details_cubit.dart';
import '../../../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../../../features/favorites/presentation/cubit/favorites_state.dart';

class StoreDetailsPage extends StatefulWidget {
  final StoreEntity store;
  const StoreDetailsPage({super.key, required this.store});

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  late final StoreDetailsCubit _cubit;

  // Tracks quantity per product
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _cubit = StoreDetailsCubit(
      getProductsByStoreUseCase: di.sl<GetProductsByStoreUseCase>(),
      storeRemoteDataSource: di.sl<StoreRemoteDataSource>(),
    );
    _cubit.loadStoreFromEntity(widget.store);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocBuilder<StoreDetailsCubit, StoreDetailsState>(
          builder: (context, state) {
            if (state.isLoadingStore) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.storeError != null || state.store == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.orange.shade400),
                      const SizedBox(height: 16),
                      Text('خطأ في تحميل المتجر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('العودة للخلف'),
                      )
                    ],
                  ),
                ),
              );
            }

            final store = state.store!;
            final products = state.products;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero AppBar (Solid Primary Color with Arc at the bottom) ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: Text(
                    store.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
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
                            context.read<FavoritesCubit>().toggleFavorite(store.id, store.name);
                          },
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 16, right: 16, bottom: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Mocking the restaurant rating and match info details in the screenshot
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('الأسعار مطابقة للمطعم', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  Container(width: 1, height: 16, color: Colors.white.withOpacity(0.5)),
                                  Row(
                                    children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.white, size: 14)),
                                  ),
                                  const Column(
                                    children: [
                                      Text('التقييمات', style: TextStyle(color: Colors.white, fontSize: 10)),
                                      Text('( 2249 )', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Delivery type toggles mock
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text('استلم بنفسك', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade500, // Golden yellow overlay for selection
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delivery_dining, color: Colors.white, size: 18),
                                        SizedBox(width: 4),
                                        Text('توصيل', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                ),

                // ── Delivery Ribbon / Status ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('مغلق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text('الطلب يستغرق 40 - 55 دقيقة', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, color: Colors.grey.shade600, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Item Groups Horizontal Tabs ───────────────────────────────────────────
                if (state.itemGroups.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.itemGroups.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final group = isAll ? null : state.itemGroups[index - 1];
                          final groupName = isAll ? "المفضلة" : (group?.groupName ?? 'Unknown');
                          final groupId = isAll ? null : group?.groupId;
                          final isSelected = state.selectedItemGroupId == groupId;
                          
                          // We mock icons/images based on name
                          IconData groupIcon = Icons.favorite_border;
                          if (groupName.contains('مقبلات')) groupIcon = Icons.tapas;
                          if (groupName.contains('أكثر')) groupIcon = Icons.local_fire_department;
                          if (groupName.contains('رئيسية')) groupIcon = Icons.restaurant;

                          return GestureDetector(
                            onTap: () => _cubit.selectTab(store.id, groupId),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8), // Replaced padding to standard RTL setup
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange.shade500 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Text(
                                    groupName,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    )
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    groupIcon,
                                    color: isSelected ? Colors.white : theme.primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Product List ─────────────────────────────────────────
                if (state.isLoadingProducts)
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                  )
                else if (products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_menu, size: 50, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text("لا توجد أصناف متاحة", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          final prodIdStr = product.id.toString();
                          return _ProductListCard(
                            product: product,
                            store: store,
                            quantity: _quantities[prodIdStr] ?? 1,
                            onQuantityChanged: (qty) => setState(() => _quantities[prodIdStr] = qty),
                            onAddToCart: () {
                              final qty = _quantities[prodIdStr] ?? 1;
                              final cartItem = CartItemEntity(
                                id: const Uuid().v4(),
                                productId: product.id,
                                productName: product.name,
                                quantity: qty,
                                unitPrice: product.unitPrice,
                                totalPrice: product.unitPrice * qty,
                                storeId: store.id,
                                storeName: store.name,
                              );
                              context.read<CartCubit>().addItem(cartItem);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تمت إضافة ${product.name} للسلة'),
                                  backgroundColor: Colors.green.shade600,
                                ),
                              );
                            },
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Redesigned Product List Card ────────────────────────────────────────────────
class _ProductListCard extends StatelessWidget {
  final ProductEntity product;
  final StoreEntity store;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _ProductListCard({
    required this.product,
    required this.store,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String imageUrl = product.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop';
    final isOption = product.name.contains('نصف') || product.name.contains('ربع');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // In screenshot it looks like slightly greyish white card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // RIGHT SIDE: Image + Favorite icon (RTL visually means it's the start, but we use TextDirection.rtl automatically)
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
                    final isFav = context.read<FavoritesCubit>().isFavorite(product.id.toString());
                    return GestureDetector(
                      onTap: () {
                        context.read<FavoritesCubit>().toggleFavorite(product.id.toString(), product.name);
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 2),
                  const Text('ريال', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                        onTap: () { if (quantity > 1) onQuantityChanged(quantity - 1); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.remove, size: 14, color: Colors.black54),
                        ),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      InkWell(
                        onTap: () => onQuantityChanged(quantity + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.add, size: 14, color: theme.primaryColor),
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
                    backgroundColor: isOption ? Colors.orange.shade400 : theme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    isOption ? 'عرض الخيارات' : 'أضف للسلة',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
