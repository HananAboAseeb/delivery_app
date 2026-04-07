import 'package:flutter/material.dart';

class StoreDetailsPage extends StatefulWidget {
  final String storeId;
  const StoreDetailsPage({super.key, required this.storeId});

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  static const Color _primary = Color(0xFFFF4500);

  final Map<String, dynamic> _store = {
    "id": "1",
    "name": "مطعم القلعة",
    "rating": 4.8,
    "ratingCount": 2223,
    "distance": "0.85 كم",
    "deliveryTime": "55 دقيقة",
    "openingHours": "7:30 ص - 11:00 م",
    "deliveryOptions": ["استلم بنفسك", "تفويض", "توصيل"],
    "products": [
      {
        "id": "p1",
        "name": "دجاج بروست",
        "description": "دجاج مقلي مقرمش بتتبيلة خاصة",
        "image": "",
        "variants": [
          {"label": "ربع", "price": 1500},
          {"label": "نصف", "price": 2500},
          {"label": "حبة", "price": 4500},
        ],
      },
      {
        "id": "p2",
        "name": "برجر كلاسيك",
        "description": "لحم بقري طازج مع خضار طازجة",
        "image": "",
        "variants": [
          {"label": "صغير", "price": 800},
          {"label": "وسط", "price": 1200},
          {"label": "كبير", "price": 1800},
        ],
      },
      {
        "id": "p3",
        "name": "شاورما عربي",
        "description": "شاورما لحم أو دجاج مع صوص بيت",
        "image": "",
        "variants": [
          {"label": "عادي", "price": 700},
          {"label": "كبير", "price": 1000},
        ],
      },
      {
        "id": "p4",
        "name": "بيتزا مارغريتا",
        "description": "بيتزا بالجبن والصلصة الإيطالية",
        "image": "",
        "variants": [
          {"label": "صغيرة", "price": 1200},
          {"label": "وسط", "price": 2000},
          {"label": "كبيرة", "price": 2800},
        ],
      },
    ],
  };

  // Tracks selected variant index per product
  final Map<String, int> _selectedVariants = {};
  // Tracks quantity per product
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    for (final p in _store['products'] as List) {
      _selectedVariants[p['id']] = 0;
      _quantities[p['id']] = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _store['products'] as List;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(Icons.store, size: 80, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // ── Store Info Card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name
                  Text(
                    _store['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),

                  // Rating row
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < _store['rating'].floor() ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 20,
                      )),
                      const SizedBox(width: 8),
                      Text(
                        '${_store['rating']} (${_store['ratingCount']})',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Delivery Options Pills
                  Row(
                    children: [
                      for (final option in _store['deliveryOptions'] as List)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      const Spacer(),
                      Icon(Icons.access_time, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _store['deliveryTime'],
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: _primary, size: 16),
                      const SizedBox(width: 4),
                      Text(_store['distance'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Text(_store['openingHours'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Menu Title ───────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('قائمة الطعام', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),

          // ── Product List ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(
                  product: products[index] as Map<String, dynamic>,
                  selectedVariantIndex: _selectedVariants[products[index]['id']] ?? 0,
                  quantity: _quantities[products[index]['id']] ?? 1,
                  onVariantChanged: (variantIdx) {
                    setState(() => _selectedVariants[products[index]['id']] = variantIdx);
                  },
                  onQuantityChanged: (qty) {
                    setState(() => _quantities[products[index]['id']] = qty);
                  },
                  onAddToCart: () {
                    final product = products[index] as Map<String, dynamic>;
                    final variantIdx = _selectedVariants[product['id']] ?? 0;
                    final qty = _quantities[product['id']] ?? 1;
                    final variant = (product['variants'] as List)[variantIdx];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة $qty ${product['name']} (${variant['label']}) إلى السلة'),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card Widget ────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int selectedVariantIndex;
  final int quantity;
  final ValueChanged<int> onVariantChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.selectedVariantIndex,
    required this.quantity,
    required this.onVariantChanged,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  static const Color _primary = Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    final variants = product['variants'] as List;
    final selectedVariant = variants[selectedVariantIndex] as Map<String, dynamic>;
    final totalPrice = selectedVariant['price'] * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          SizedBox(
            height: 160,
            child: Image.network(product['image'], fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + description
                Text(product['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(product['description'], style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),

                const SizedBox(height: 14),

                // Variant selector
                const Text('اختر الحجم:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(variants.length, (i) {
                      final v = variants[i] as Map<String, dynamic>;
                      final isSelected = i == selectedVariantIndex;
                      return GestureDetector(
                        onTap: () => onVariantChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _primary : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? _primary : Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                v['label'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${v['price']}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                // Quantity + Add to Cart Row
                Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () {
                              if (quantity > 1) onQuantityChanged(quantity - 1);
                            },
                          ),
                          Text(quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 18, color: _primary),
                            onPressed: () => onQuantityChanged(quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add to cart button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.white),
                          label: Text(
                            'أضف للسلة  •  $totalPrice',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
