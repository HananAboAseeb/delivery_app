import 'package:flutter/material.dart';

/// The ribbon showing open/closed status and average delivery time.
class StoreDeliveryRibbon extends StatelessWidget {
  const StoreDeliveryRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('مغلق',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text('الطلب يستغرق 40 - 55 دقيقة',
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(width: 8),
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
