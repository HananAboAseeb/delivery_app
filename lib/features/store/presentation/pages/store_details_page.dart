import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/store/domain/entities/store_entity.dart';

import 'package:my_store/features/store/data/datasources/store_remote_datasource.dart';
import 'package:my_store/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';

import '../cubit/store_details_cubit.dart';

class StoreDetailsPage extends StatefulWidget {
  final StoreEntity store;
  const StoreDetailsPage({super.key, required this.store});

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  static const Color _primary = Color(0xFFFF4500);

  late final StoreDetailsCubit _cubit;

  // Tracks selected variant index per product
  final Map<String, int> _selectedVariants = {};
  // Tracks quantity per product
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();

    _cubit = StoreDetailsCubit(
      getProductsByStoreUseCase: di.sl<GetProductsByStoreUseCase>(),
      storeRemoteDataSource: di.sl<StoreRemoteDataSource>(),
    );

    // Load from the pre-fetched StoreEntity — fetches categories & products from API
    _cubit.loadStoreFromEntity(widget.store);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'خطأ في تحميل المتجر',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.storeError ?? "متجر غير موجود",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('العودة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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
                // ── Hero AppBar ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: store.imageUrl != null && store.imageUrl!.isNotEmpty
                              ? Image.network(store.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Center(child: Icon(Icons.store, size: 80, color: Theme.of(context).primaryColor)))
                              : Center(child: Icon(Icons.store, size: 80, color: Theme.of(context).primaryColor)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),

                // ── Store Info Card ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store name
                        Text(
                          store.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),

                        // Rating row
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < 4 ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 20,
                            )),
                            const SizedBox(width: 8),
                            Text(
                              '4.5 (100+)', // Mocked rating for now, update when API supports it
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Delivery Options Pills
                        Row(
                          children: [
                            for (final option in ["توصيل"]) // Mock delivery options
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _primary.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Icon(Icons.access_time, color: Colors.grey.shade500, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "20-30 دقيقة", // Mock time
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: _primary, size: 16),
                            const SizedBox(width: 4),
                            // Optional distance (not present in StoreEntity yet)
                            Text("1.5 كم", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(width: 16),
                            Icon(Icons.schedule, color: Colors.grey.shade500, size: 16),
                            const SizedBox(width: 4),
                            Text("7:00 ص - 11:00 م", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Item Groups Horizontal Tabs ───────────────────────────────────────────
                if (state.itemGroups.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.itemGroups.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final group = isAll ? null : state.itemGroups[index - 1];
                          final groupName = isAll ? "جميع الأصناف" : (group?.groupName ?? 'Unknown');
                          final groupId = isAll ? null : group?.groupId;
                          final isSelected = state.selectedItemGroupId == groupId;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                            child: FilterChip(
                              label: Text(groupName, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                              selected: isSelected,
                              onSelected: (_) => _cubit.selectTab(store.id, groupId),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: _primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? _primary : Colors.grey.shade300)),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                   const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('جميع الأصناف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),

                // ── Product List ─────────────────────────────────────────
                if (state.isLoadingProducts)
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                  )
                else if (state.productsError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 50, color: Colors.orange.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              "لا توجد أصناف متاحة حالياً",
                              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "يرجى المحاولة لاحقاً",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _cubit.fetchProducts(store.id),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('إعادة المحاولة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _primary,
                                side: BorderSide(color: _primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            const Text(
                              "لا توجد أصناف متاحة",
                              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "سيتم إضافة الأصناف قريباً",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
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
                          return _ProductCard(
                            product: product,
                            // we pass 0 for variants because we don't have variants right now.
                            // but later we can map it. For now, it stays as is to retain compilation
                            selectedVariantIndex: _selectedVariants[prodIdStr] ?? 0,
                            quantity: _quantities[prodIdStr] ?? 1,
                            onVariantChanged: (variantIdx) {
                              setState(() => _selectedVariants[prodIdStr] = variantIdx);
                            },
                            onQuantityChanged: (qty) {
                              setState(() => _quantities[prodIdStr] = qty);
                            },
                            onAddToCart: () {
                              final qty = _quantities[prodIdStr] ?? 1;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تمت إضافة $qty ${product.name} إلى السلة'),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ── Product Card Widget ────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final int selectedVariantIndex;
  final int quantity;
  final ValueChanged<int> onVariantChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.selectedVariantIndex,
    required this.quantity,
    required this.onVariantChanged,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  static const Color _primary = Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    // If no variants in Entity, we can use base product. 
    // In Entity, we might have modifiers or variants later.
    final price = product.unitPrice;
    final totalPrice = price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          SizedBox(
            height: 160,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200, child: Icon(Icons.fastfood, size: 50, color: Colors.grey.shade400)))
                : Container(color: Colors.grey.shade200, child: Icon(Icons.fastfood, size: 50, color: Colors.grey.shade400)),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + description
                Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Since product doesn't have a description right now, we skip it
                // You can add logic for description here when available in API

                const SizedBox(height: 14),

                // the hasVariants block is removed because we mock hasVariants to false

                const SizedBox(height: 16),

                // Quantity + Add to Cart Row
                Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () {
                              if (quantity > 1) onQuantityChanged(quantity - 1);
                            },
                          ),
                          Text(quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 18, color: _primary),
                            onPressed: () => onQuantityChanged(quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add to cart button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.white),
                          label: Text(
                            'أضف للسلة  •  $totalPrice',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
