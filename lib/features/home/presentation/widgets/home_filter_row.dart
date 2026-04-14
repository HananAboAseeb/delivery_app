import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_store/features/home/logic/home_cubit.dart';
import 'package:my_store/features/home/presentation/widgets/filter_chip_widget.dart';

/// The horizontal filter tabs row (الكل, الأقرب, الجديدة, المفضلة).
class HomeFilterRow extends StatelessWidget {
  static const List<String> _filters = ['الكل', 'الأقرب', 'الجديدة', 'المفضلة'];

  const HomeFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) => prev.selectedFilter != curr.selectedFilter,
      builder: (context, state) {
        return SizedBox(
          height: 40,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = state.selectedFilter == filter ||
                  (index == 0 && state.selectedFilter == 'الكل');
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FilterChipWidget(
                  label: filter,
                  isSelected: isSelected,
                  onTap: () => context.read<HomeCubit>().selectFilter(filter),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
