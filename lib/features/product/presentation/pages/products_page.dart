import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import 'package:uuid/uuid.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ProductBloc>().add(const FetchProductsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading && state is! ProductsLoaded) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final product = state.products[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('\$${product.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<CartCubit>().addItem(CartItemEntity(
                                    id: const Uuid().v4(),
                                    productId: product.id,
                                    productName: product.name,
                                    quantity: 1,
                                    unitPrice: product.unitPrice,
                                    totalPrice: product.unitPrice,
                                    storeId: 'Store1', // For demo
                                    storeName: 'Main Store',
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart'), duration: Duration(seconds: 1)));
                                },
                                child: const Text('Add to Cart'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
