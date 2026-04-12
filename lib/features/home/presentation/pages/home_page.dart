import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:my_store/service_locator.dart' as di;
import 'package:my_store/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_store/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:my_store/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:my_store/features/favorites/presentation/pages/favorites_page.dart';

import '../widgets/filter_chip_widget.dart';
import '../widgets/category_icon.dart';
import '../widgets/store_card_widget.dart';
import '../widgets/offers_slider.dart';

import 'package:my_store/features/search/presentation/pages/search_page.dart';
import 'package:my_store/features/cart/presentation/pages/cart_page.dart';
import 'package:my_store/features/profile/presentation/pages/profile_page.dart';
import 'package:my_store/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:my_store/features/profile/presentation/cubit/profile_state.dart';

import 'package:my_store/features/store/presentation/pages/store_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;

  late final FavoritesCubit _favoritesCubit;
  late final HomeCubit _homeCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();

    // Use DI to get shared instances with proper auth token
    _favoritesCubit = FavoritesCubit(const FlutterSecureStorage());
    _homeCubit = di.sl<HomeCubit>();
    _profileCubit = ProfileCubit(const FlutterSecureStorage());
  }

  @override
  void dispose() {
    _favoritesCubit.close();
    _homeCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _favoritesCubit),
        BlocProvider.value(value: _homeCubit),
        BlocProvider.value(value: _profileCubit),
      ],
      child: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          _homeCubit.syncFavorites(state.favoriteStoreNames.toList());
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: IndexedStack(
            index: _bottomNavIndex,
            children: [
              const HomeTab(),
              const SearchPage(),
              const CartPage(),
              const FavoritesPage(),
              const ProfilePage(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  IconData _getIconForCategory(String name) {
    if (name.contains('مطاعم')) return Icons.restaurant;
    if (name.contains('كوفي')) return Icons.local_cafe;
    if (name.contains('بقالة') || name.contains('ماركت')) return Icons.store;
    if (name.contains('صيدلية')) return Icons.local_pharmacy;
    if (name.contains('هدايا')) return Icons.card_giftcard;
    if (name.contains('ملابس')) return Icons.checkroom;
    if (name.contains('إلكترونيات')) return Icons.devices;
    return Icons.category;
  }

  final List<String> _filters = ['الكل', 'الأقرب', 'الجديدة', 'المفضلة'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favs = context.read<FavoritesCubit>().state.favoriteStoreNames.toList();
      context.read<HomeCubit>().loadInitialData(favs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFFF4500);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- AppBar ---
            SliverAppBar(
              pinned: true,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0, // Removes shadow as requested
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.adjust_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'WASL',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // --- Scrollable Layout Content (No forced heights!) ---
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  // 1. Greeting and Location
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            String name = 'عزيزي العميل';
                            if (state is ProfileLoaded) {
                              name = state.profile.name.isNotEmpty ? state.profile.name : 'عزيزي العميل';
                            }
                            return Text(
                              'مرحباً، $name 👋',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: primaryColor, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'اليمن، صنعاء، شارع حدة',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // 2. Search Bar (Smaller height)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 45, // Smaller height explicitly as requested
                      child: TextField(
                        onChanged: (val) {
                          context.read<HomeCubit>().updateSearchQuery(val);
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مطعم، منتج، أو متجر...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.zero, // Forces vertical alignment to respect custom height
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Popular Categories Icons Row
                  SizedBox(
                    height: 90, // Natural height buffer for items inside
                    child: state.isLoadingGroups
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: state.storeGroups.length,
                            itemBuilder: (context, index) {
                              final group = state.storeGroups[index];
                              return CategoryIcon(
                                label: group.name ?? 'Unknown',
                                icon: _getIconForCategory(group.name ?? ''),
                                isSelected: state.selectedGroupId == group.id,
                                onTap: () {
                                  context.read<HomeCubit>().selectCategory(group.name ?? '', group.id);
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Offers Slider
                  const OffersSlider(),

                  const SizedBox(height: 20),

                  // 5. Filter Tabs (Horizontal)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        return FilterChipWidget(
                          label: _filters[index],
                          isSelected: state.selectedFilter == _filters[index],
                          onTap: () {
                            context.read<HomeCubit>().selectFilter(_filters[index]);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // 6. Results Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.selectedCategory == 'الكل'
                              ? (state.searchQuery.isNotEmpty ? 'نتائج البحث' : 'المنتجات المتاحة')
                              : 'نتائج البحث (${state.selectedCategory})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.stores.length} نتائج',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 7. Results Grid: Show stores if they exist, otherwise show products
            _buildResultsGrid(state, theme),
          ],
        );
      },
    );
  }

  Widget _buildResultsGrid(HomeState state, ThemeData theme) {
    final primaryColor = const Color(0xFFFF4500);
    
    // If stores exist, show stores grid
    if (state.stores.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 32),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final store = state.stores[index];
              return StoreCardWidget(
                name: store.name,
                category: state.selectedCategory != 'الكل' ? state.selectedCategory : 'متجر',
                distance: 'يحدد لاحقا',
                rating: 4.5,
                deliveryTime: '20-30 دقيقة',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreDetailsPage(store: store),
                    ),
                  );
                },
              );
            },
            childCount: state.stores.length,
          ),
        ),
      );
    }

    // Show loading indicator
    if (state.isLoadingStores || state.isLoadingProducts) {
      return SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'جاري جلب البيانات...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        )),
      );
    }

    // No stores → show products ONLY if no specific category is selected
    // When a specific category is selected (like بهارات), don't show random global products
    if (state.products.isNotEmpty && (state.selectedCategory == 'الكل' || state.selectedGroupId == null)) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 32),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = state.products[index];
              return _ProductGridCard(product: product);
            },
            childCount: state.products.length,
          ),
        ),
      );
    }

    // Error state → show error with retry
    if (state.errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.orange.shade400),
                const SizedBox(height: 12),
                Text(
                  'حدث خطأ',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    final favs = context.read<FavoritesCubit>().state.favoriteStoreNames.toList();
                    context.read<HomeCubit>().loadInitialData(favs);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No data at all
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 50, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'لا توجد نتائج',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم العثور على متاجر أو منتجات حالياً',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  final favs = context.read<FavoritesCubit>().state.favoriteStoreNames.toList();
                  context.read<HomeCubit>().loadInitialData(favs);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product card shown in the home grid when no stores exist
class _ProductGridCard extends StatelessWidget {
  final dynamic product; // ProductEntity

  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF4500);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.unitPrice.toStringAsFixed(0)} ${product.currencyName}',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Icon(Icons.add_circle, color: primaryColor, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(Icons.fastfood, color: Colors.grey.shade300, size: 48),
    );
  }
}
