import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/store/logic/store_details_cubit.dart';

/// The horizontal scrollable row of item groups (categories) within a store.
class StoreItemGroupsTabs extends StatelessWidget {
  final String storeId;

  const StoreItemGroupsTabs({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StoreDetailsCubit, StoreDetailsState>(
      buildWhen: (prev, curr) =>
          prev.itemGroups != curr.itemGroups ||
          prev.selectedItemGroupId != curr.selectedItemGroupId,
      builder: (context, state) {
        if (state.itemGroups.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.itemGroups.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final group = isAll ? null : state.itemGroups[index - 1];
              final groupName =
                  isAll ? "المفضلة" : (group?.groupName ?? 'Unknown');
              final groupId = isAll ? null : group?.groupId;
              final isSelected = state.selectedItemGroupId == groupId;

              // Mock icons based on name
              IconData groupIcon = Icons.favorite_border;
              if (groupName.contains('مقبلات')) groupIcon = Icons.tapas;
              if (groupName.contains('أكثر'))
                groupIcon = Icons.local_fire_department;
              if (groupName.contains('رئيسية')) groupIcon = Icons.restaurant;

              return GestureDetector(
                onTap: () => context
                    .read<StoreDetailsCubit>()
                    .selectTab(storeId, groupId),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.shade500
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
        );
      },
    );
  }
}
