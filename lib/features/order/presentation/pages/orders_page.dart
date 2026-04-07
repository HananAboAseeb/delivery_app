import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('طلباتي', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          bottom: TabBar(
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: theme.primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: "جارية"),
              Tab(text: "مكتملة"),
              Tab(text: "ملغية"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(statusFilter: "جارية"),
            _OrderList(statusFilter: "مكتملة"),
            _OrderList(statusFilter: "ملغية"),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String statusFilter;
  
  const _OrderList({required this.statusFilter});

  static final List<Map<String, dynamic>> _mockOrders = [
    {
      "id": "#ORD-8821",
      "store": "السندباد",
      "total": 29.50,
      "date": "12 أبريل 2024",
      "status": "جارية",
      "itemsCount": 3,
    },
    {
      "id": "#ORD-8510",
      "store": "كوفي شوب روز",
      "total": 14.00,
      "date": "10 أبريل 2024",
      "status": "مكتملة",
      "itemsCount": 2,
    },
    {
      "id": "#ORD-8104",
      "store": "مطعم الاسطورة",
      "total": 45.99,
      "date": "5 أبريل 2024",
      "status": "مكتملة",
      "itemsCount": 5,
    },
    {
      "id": "#ORD-7992",
      "store": "بقالة العثيم",
      "total": 12.50,
      "date": "1 أبريل 2024",
      "status": "ملغية",
      "itemsCount": 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredOrders = _mockOrders.where((o) => o['status'] == statusFilter).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('لا توجد طلبات $statusFilter', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        
        Color statusColor;
        if (order['status'] == 'جارية') {
          statusColor = Colors.orange;
        } else if (order['status'] == 'مكتملة') {
          statusColor = Colors.green;
        } else {
          statusColor = Colors.red;
        }
        
        return GestureDetector(
          onTap: () {
            // Mock Navigation logic to order tracking
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فتح تفاصيل الطلب ${order['id']}')));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['status'], 
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.storefront, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['store'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${order['itemsCount']} عناصر • ${order['date']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      '\$${order['total'].toStringAsFixed(2)}', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
