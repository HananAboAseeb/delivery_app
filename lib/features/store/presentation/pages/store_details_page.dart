import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/data/datasources/store_remote_datasource.dart';
import 'package:my_store/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:my_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_store/features/cart/logic/cart_cubit.dart';
import 'package:my_store/features/store/logic/store_details_cubit.dart';

import 'package:my_store/features/store/presentation/widgets/store_hero_app_bar.dart';
import 'package:my_store/features/store/presentation/widgets/store_delivery_ribbon.dart';
import 'package:my_store/features/store/presentation/widgets/store_item_groups_tabs.dart';
import 'package:my_store/features/store/presentation/widgets/product_list_card.dart';

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
              return _ErrorView(onBack: () => Navigator.pop(context));
            }

            final store = state.store!;
            final products = state.products;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                StoreHeroAppBar(store: store),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: StoreDeliveryRibbon(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StoreItemGroupsTabs(storeId: store.id),
                  ),
                ),
                _ProductsSection(
                  isLoading: state.isLoadingProducts,
                  products: products,
                  store: store,
                  quantities: _quantities,
                  onQuantityChanged: (id, qty) =>
                      setState(() => _quantities[id] = qty),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onBack;

  const _ErrorView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            Text('خطأ في تحميل المتجر',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700)),
            TextButton(
              onPressed: onBack,
              child: const Text('العودة للخلف'),
            )
          ],
        ),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> products;
  final StoreEntity store;
  final Map<String, int> quantities;
  final void Function(String, int) onQuantityChanged;

  const _ProductsSection({
    required this.isLoading,
    required this.products,
    required this.store,
    required this.quantities,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.restaurant_menu,
                    size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text("لا توجد أصناف متاحة",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            final prodIdStr = product.id.toString();
            return ProductListCard(
              product: product,
              store: store,
              quantity: quantities[prodIdStr] ?? 1,
              onQuantityChanged: (qty) => onQuantityChanged(prodIdStr, qty),
              onAddToCart: () {
                final qty = quantities[prodIdStr] ?? 1;
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
    );
  }
}
