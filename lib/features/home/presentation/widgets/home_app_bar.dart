import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_store/features/home/logic/home_cubit.dart';

class HomeAppBar extends StatefulWidget {
  final FocusNode searchFocusNode;
  const HomeAppBar({super.key, required this.searchFocusNode});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _userName = 'زائر';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'profile_name');
    final avatar = await storage.read(key: 'profile_avatar');
    if (mounted) {
      setState(() {
        _userName = name?.isNotEmpty == true ? name! : 'زائرنا العزيز';
        _avatarUrl = avatar ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Well-balanced height to ensure it sits safely below the notch and holds the UI perfectly
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.primaryColor,
      expandedHeight: 185, 
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: theme.primaryColor),
            
            // Decorative transparent lighter orange circles
            Positioned(
              top: -30,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 80,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                // This ensures everything stays grouped beautifully at the bottom, 
                // heavily running away from the top status bar/notch!
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Info
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 20, 
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                                  child: _avatarUrl.isEmpty ? const Icon(Icons.person_rounded, size: 22, color: Colors.white) : null,
                                ),
                              ),
                              const SizedBox(width: 10), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحباً بك، $_userName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15, 
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, color: Colors.white.withOpacity(0.8), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'اليمن، صنعاء',
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Cart Icon
                        GestureDetector(
                          onTap: () => context.push('/cart'),
                          child: Container(
                            padding: const EdgeInsets.all(8), 
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Strict, beautiful fixed distance between Avatar and Search Bar (Not too far, not too close)
                  const SizedBox(height: 20),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SearchBar(focusNode: widget.searchFocusNode, theme: theme),
                  ),
                  
                  // Gap between the search bar and the white edge curve beneath it
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final FocusNode focusNode;
  final ThemeData theme;

  const _SearchBar({required this.focusNode, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, color: theme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              onChanged: (val) => context.read<HomeCubit>().updateSearchQuery(val),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم، وجبة...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 6),
              ),
            ),
          ),
          Icon(Icons.search_rounded, color: theme.primaryColor, size: 24),
        ],
      ),
    );
  }
}
