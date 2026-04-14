import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/home/logic/home_cubit.dart';

/// A custom sliver app bar for the home screen that contains
/// the gradient header, location display, and animated search field.
class HomeAppBar extends StatelessWidget {
  final FocusNode searchFocusNode;

  const HomeAppBar({super.key, required this.searchFocusNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.primaryColor,
      expandedHeight: 170,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient background
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
            // Decorative circle
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeTopRow(theme: theme),
                    const SizedBox(height: 4),
                    _LocationRow(),
                    const SizedBox(height: 6),
                    _SearchBar(focusNode: searchFocusNode, theme: theme),
                  ],
                ),
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
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTopRow extends StatelessWidget {
  final ThemeData theme;

  const _HomeTopRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.adjust_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'خلك مرتاح',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'اليمن، صنعاء، الحصبة، حارة النصر',
            style:
                TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
      ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus ? theme.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              onChanged: (val) =>
                  context.read<HomeCubit>().updateSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم، وجبة...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 2),
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
    );
  }
}
