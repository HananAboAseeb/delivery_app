import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/home/logic/home_cubit.dart';
import 'package:my_store/features/home/presentation/widgets/category_icon.dart';

/// Displays the horizontal scrollable list of store categories
/// fetched from the API, with loading state and grayscale/color toggle.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  String _imageForCategory(String name) {
    if (name.contains('مطاعم')) {
      return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('كوفي') || name.contains('كافيه')) {
      return 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('بقالة') || name.contains('ماركت')) {
      return 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('صيدل')) {
      return 'https://images.unsplash.com/photo-1576602976047-174e57a47881?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('هدايا')) {
      return 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('لابس') || name.contains('أزياء')) {
      return 'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('بهارات')) {
      return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?q=80&w=300&auto=format&fit=crop';
    }
    if (name.contains('خضروات')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=300&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1580828369019-2220d58a0cb0?q=80&w=300&auto=format&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) =>
          prev.isLoadingGroups != curr.isLoadingGroups ||
          prev.storeGroups != curr.storeGroups ||
          prev.selectedGroupId != curr.selectedGroupId,
      builder: (context, state) {
        if (state.isLoadingGroups) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.storeGroups.length,
            itemBuilder: (context, index) {
              final group = state.storeGroups[index];
              return CategoryIcon(
                label: group.name ?? 'Unknown',
                imageUrl: _imageForCategory(group.name ?? ''),
                isSelected: state.selectedGroupId == group.id,
                onTap: () {
                  context
                      .read<HomeCubit>()
                      .selectCategory(group.name ?? '', group.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}
