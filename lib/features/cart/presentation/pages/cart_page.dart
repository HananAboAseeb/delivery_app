import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_store/features/cart/logic/cart_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final double deliveryFee = 1500.00; // Adjusted for local currency approx

  @override
  void initState() {
    super.initState();
    // Load cart when page initializes
    context.read<CartCubit>().loadCart();
  }

  void _removeItem(String id) {
    context.read<CartCubit>().removeItem(id);
  }

  void _updateQuantity(String id, int currentQty, int delta) {
    final newQty = currentQty + delta;
    if (newQty > 0) {
      context.read<CartCubit>().updateQuantity(id, newQty);
    } else {
      _removeItem(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          'سلة المشتريات', 
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.black87
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartError) {
            return Center(
                child: Text("حدث خطأ: ${state.message}",
                    style: const TextStyle(color: Colors.red)));
          } else if (state is CartLoaded) {
            final items = state.items;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_basket_outlined,
                          size: 80, color: theme.primaryColor.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    Text('سلتك فارغة تماماً',
                        style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    Text('يبدو أنك لم تضف أي أطباق شهية بعد',
                        style: GoogleFonts.cairo(
                            fontSize: 15, color: Colors.grey.shade500)),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () => context.go('/home'),
                      child: Text('اكتشف المطاعم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    )
                  ],
                ),
              );
            }

            final subtotal = state.totalAmount;
            final total = subtotal + deliveryFee;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // High quality mock image via ui-avatars
                      final imageUrl =
                          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(item.productName)}&background=FFE0B2&color=F57C00&size=128&rounded=false&font-size=0.4";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Beautiful rounded image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(imageUrl,
                                    width: 90, height: 90, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.productName,
                                          style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => _removeItem(item.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.delete_outline_rounded,
                                              color: Colors.red.shade400, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.storeName,
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '${item.unitPrice.toStringAsFixed(0)} ر.ي',
                                          style: GoogleFonts.cairo(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18)),
                                      
                                      // Elegant Quantity Selector
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            _qtyButton(
                                                Icons.remove_rounded,
                                                () => _updateQuantity(
                                                    item.id, item.quantity, -1)),
                                            Container(
                                              constraints: const BoxConstraints(minWidth: 24),
                                              alignment: Alignment.center,
                                              child: Text(item.quantity.toString(),
                                                  style: GoogleFonts.cairo(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87)),
                                            ),
                                            _qtyButton(
                                                Icons.add_rounded,
                                                () => _updateQuantity(
                                                    item.id, item.quantity, 1), isAdd: true, theme: theme),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Premium Checkout Section
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, -5))
                    ],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _summaryRow('قيمة الطلب', subtotal),
                        const SizedBox(height: 12),
                        _summaryRow('رسوم التوصيل', deliveryFee),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.grey.shade200, thickness: 1.5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الإجمالي',
                                style: GoogleFonts.cairo(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('${total.toStringAsFixed(0)} ر.ي',
                                style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: theme.primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 28),
                        
                        // Grand Checkout Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ]
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CartCubit>().clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text('تم استقبال الطلب بنجاح! شكراً لك', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF43A047),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  margin: const EdgeInsets.all(20),
                                  elevation: 5,
                                ),
                              );
                              context.go('/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: Text('تأكيد وإتمام الطلب',
                                style: GoogleFonts.tajawal(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("جاري تحميل السلة..."));
        },
      ),
    );
  }

  Widget _summaryRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        Text('${amount.toStringAsFixed(0)} ر.ي',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, {bool isAdd = false, ThemeData? theme}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isAdd ? theme?.primaryColor : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isAdd ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Icon(icon, size: 18, color: isAdd ? Colors.white : Colors.black87),
      ),
    );
  }
}
