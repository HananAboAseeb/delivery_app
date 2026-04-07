import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    _favoritesCubit = FavoritesCubit(const FlutterSecureStorage());
    _homeCubit = HomeCubit();
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
  final List<Map<String, dynamic>> _categories = [
    {'name': 'مطاعم', 'icon': Icons.restaurant},
    {'name': 'كوفي شوب', 'icon': Icons.local_cafe},
    {'name': 'بقالة', 'icon': Icons.store},
    {'name': 'صيدلية', 'icon': Icons.local_pharmacy},
    {'name': 'تحف وهدايا', 'icon': Icons.card_giftcard},
    {'name': 'ملابس', 'icon': Icons.checkroom},
    {'name': 'إلكترونيات', 'icon': Icons.devices},
  ];

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
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return CategoryIcon(
                          label: cat['name'],
                          icon: cat['icon'],
                          isSelected: state.selectedCategory == cat['name'],
                          onTap: () {
                            context.read<HomeCubit>().selectCategory(cat['name']);
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
                              ? (state.searchQuery.isNotEmpty ? 'النتائج البحث' : 'أماكن مقترحة')
                              : 'النتائج البحث (${state.selectedCategory})',
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

            // 7. Results Grid Block
            state.stores.isEmpty
                ? SliverToBoxAdapter(
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
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
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
                            name: store['name'],
                            category: store['category'],
                            distance: '${store['distance']} كم',
                            rating: store['rating'].toDouble(),
                            deliveryTime: store['time'],
                            onTap: () {},
                          );
                        },
                        childCount: state.stores.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
