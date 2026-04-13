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
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = di.sl<HomeCubit>();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        // Sync the favorites across so UI can filter if needed
        _homeCubit.syncFavorites(state.favoriteStoreIds.toList());
      },
      child: BlocProvider<HomeCubit>.value(
        value: _homeCubit,
        child: const Scaffold(
          backgroundColor: Color(0xFFFAFAFA),
          body: HomeTab(),
        ),
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
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favs = context.read<FavoritesCubit>().state.favoriteStoreIds.toList();
      context.read<HomeCubit>().loadInitialData(favs);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getImageForCategory(String name) {
    if (name.contains('مطاعم')) return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop';
    if (name.contains('كوفي') || name.contains('كافيه')) return 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=300&auto=format&fit=crop';
    if (name.contains('بقالة') || name.contains('ماركت')) return 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=300&auto=format&fit=crop';
    if (name.contains('صيدل')) return 'https://images.unsplash.com/photo-1576602976047-174e57a47881?q=80&w=300&auto=format&fit=crop';
    if (name.contains('هدايا')) return 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=300&auto=format&fit=crop';
    if (name.contains('لابس') || name.contains('أزياء')) return 'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=300&auto=format&fit=crop';
    if (name.contains('بهارات')) return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?q=80&w=300&auto=format&fit=crop';
    if (name.contains('خضروات')) return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=300&auto=format&fit=crop';
    return 'https://images.unsplash.com/photo-1580828369019-2220d58a0cb0?q=80&w=300&auto=format&fit=crop'; 
  }

  final List<String> _filters = ['الكل', 'الأقرب', 'الجديدة', 'المفضلة'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Custom Highly Professional Header with Search Bar Inside ---
            SliverAppBar(
              pinned: true,
              backgroundColor: theme.primaryColor,
              expandedHeight: 140, // Reduced from 180 as requested
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Red Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    // Glassmorphic pattern or circles can be added here
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.adjust_rounded, color: Colors.white, size: 28),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'خلك مرتاح',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                                      },
                                      child: const CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.white24,
                                        child: Icon(Icons.person, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Location text
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'اليمن، صنعاء، الحصبة، حارة النصر',
                                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Elegant Inner Search Bar
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _searchFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: theme.primaryColor, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      focusNode: _searchFocusNode,
                                      onChanged: (val) {
                                        context.read<HomeCubit>().updateSearchQuery(val);
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'ابحث عن مطعم، وجبة...',
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(bottom: 2), // Align text properly
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.grey.shade300,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  Icon(Icons.tune, color: theme.primaryColor, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0), // No extra bottom space, background arc handles it
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA), // Matches Scaffold background
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            // --- Body Content ---
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Operational Hours Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_filled, color: Colors.orange.shade400, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'أوقات الدوام من 7:30 الصباح وحتى 11 المساء',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Image-based Categories Row (Using CategoryImageWidget with Grayscale inside)
                  SizedBox(
                    height: 110, 
                    child: state.isLoadingGroups
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: state.storeGroups.length,
                            itemBuilder: (context, index) {
                              final group = state.storeGroups[index];
                              return CategoryIcon(
                                label: group.name ?? 'Unknown',
                                imageUrl: _getImageForCategory(group.name ?? ''),
                                isSelected: state.selectedGroupId == group.id,
                                onTap: () {
                                  context.read<HomeCubit>().selectCategory(group.name ?? '', group.id);
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Stunning Ads Banner 
                  const OffersSlider(),

                  const SizedBox(height: 20),

                  // Filter Tabs
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilterChipWidget(
                            label: filter,
                            isSelected: state.selectedFilter == filter || (index == 0 && state.selectedFilter == 'الكل'),
                            onTap: () {
                              context.read<HomeCubit>().selectFilter(filter);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // --- Stores List replacing Grid (List vertical design like screenshot) ---
            if (state.isLoadingStores)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('خطأ في تحميل المتاجر', style: TextStyle(color: Colors.grey.shade600)),
                      TextButton(
                        onPressed: () {
                          context.read<HomeCubit>().fetchStores(groupId: state.selectedGroupId);
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.stores.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('لا توجد بيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final store = state.stores[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailsPage(store: store),
                            ),
                          );
                        },
                        child: StoreCardRedesigned(
                          store: store,
                          onFavoriteToggled: () {
                            context.read<FavoritesCubit>().toggleFavorite(store.id, store.name);
                          },
                        ),
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

// ── New Store Card List Design ──────────────────────────────────────────────
class StoreCardRedesigned extends StatelessWidget {
  final dynamic store;
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top section (Image right + Info left) RTL means info is Right, Image is Left actually!
          // BUT screenshot shows Info on Right and smaller Image on Left like a ListTile!
          // Oh wait, screenshot: "مطعم القلعة" on right, small circular/square image on rightmost side.
          // Wait, Logo is on RIGHTmost side, then title, then "10.33 كيلو" on LEFTmost side.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Image (Logo)
                Container(
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
                ),
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'شارع الخمسين جوار سما مول', // Mock address since API might not have it
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Tags row
                      Row(
                        children: [
                          _buildTag('توصيل برو', Icons.delivery_dining, theme.primaryColor),
                          const SizedBox(width: 8),
                          _buildTag('استلم بنفسك', Icons.shopping_bag_outlined, Colors.black87),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Distance & Favorite
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '10.33 كيلو',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFavorite = context.read<FavoritesCubit>().isFavorite(store.id);
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
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
          
          // Bottom section: Closed status or Rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900, // "مغلق" color from screenshot
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('مغلق', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star, color: theme.primaryColor, size: 14)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
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
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
