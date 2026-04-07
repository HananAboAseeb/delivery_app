import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_store/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:my_store/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:my_store/features/home/presentation/widgets/store_card_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  // Re-using the mock data
  static const List<Map<String, dynamic>> _allStores = [
    {'name': 'السندباد', 'category': 'مطاعم', 'distance': 0.85, 'rating': 4.5, 'time': '30-45 دقيقة'},
    {'name': 'مطعم الاسطورة', 'category': 'مطاعم', 'distance': 0.92, 'rating': 3.2, 'time': '20-30 دقيقة'},
    {'name': 'الطماطم الأسري', 'category': 'مطاعم', 'distance': 1.5, 'rating': 4.7, 'time': '40-55 دقيقة'},
    {'name': 'كوفي شوب روز', 'category': 'كوفي شوب', 'distance': 0.6, 'rating': 4.8, 'time': '15-25 دقيقة'},
    {'name': 'بقالة العثيم', 'category': 'بقالة', 'distance': 1.2, 'rating': 4.6, 'time': '25-35 دقيقة'},
    {'name': 'سوبر ماركت مانويل', 'category': 'بقالة', 'distance': 0.9, 'rating': 4.9, 'time': '20-30 دقيقة'},
    {'name': 'صيدلية النهدي', 'category': 'صيدلية', 'distance': 1.8, 'rating': 4.5, 'time': '30-45 دقيقة'},
    {'name': 'هدايا ورد', 'category': 'تحف وهدايا', 'distance': 2.0, 'rating': 4.2, 'time': '45-60 دقيقة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final favList = _allStores.where((store) => state.isFavorite(store['name'])).toList();

          if (favList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'قائمة المفضلة فارغة',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Matches the home page ratio
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final store = favList[index];
              return StoreCardWidget(
                name: store['name'],
                category: store['category'],
                distance: '${store['distance']} كم',
                rating: store['rating'].toDouble(),
                deliveryTime: store['time'],
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
