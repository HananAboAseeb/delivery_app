import 'dart:async';
import 'package:flutter/material.dart';

class OffersSlider extends StatefulWidget {
  const OffersSlider({Key? key}) : super(key: key);

  @override
  State<OffersSlider> createState() => _OffersSliderState();
}

class _OffersSliderState extends State<OffersSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Modern Split-style cards with highly reliable FlatIcon transparent PNGs
  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'احصل على',
      'highlight': 'خصم 20%',
      'action': 'استمتع بتوصيل مجاني لطلبك الأول',
      'image': 'https://cdn-icons-png.flaticon.com/512/3014/3014502.png', // Premium transparent Burger
      'plateOffset': const Offset(10, 0),
    },
    {
      'title': 'وجبتك المفضلة',
      'highlight': 'خصم 35%',
      'action': 'تصفح أشهى العروض الآن',
      'image': 'https://cdn-icons-png.flaticon.com/512/3014/3014491.png', // Premium transparent Pizza
      'plateOffset': const Offset(10, 0),
    },
    {
      'title': 'طبق اليوم',
      'highlight': 'توصيل مجاني',
      'action': 'اطلب أكثر من 3000 ريال',
      'image': 'https://cdn-icons-png.flaticon.com/512/3014/3014488.png', // Premium transparent Chicken
      'plateOffset': const Offset(10, 0),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Using matching app color for all sliders! No heavy gradients.
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Decorative subtle sunburst/stripes effect representing the background art
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SunburstPainter(),
                        ),
                      ),
                      
                      // Food Image (Transparent PNG seamlessly integrated)
                      Positioned(
                        left: offer['plateOffset'].dx,
                        top: offer['plateOffset'].dy,
                        bottom: -offer['plateOffset'].dy,
                        width: 140, // Scaled better for FlatIcon
                        child: Center(
                          child: Image.network(
                            offer['image'],
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain, // Maintain Aspect Ratio of PNG nicely
                          ),
                        ),
                      ),
                      
                      // Typography Content (RTL Aligned to Right)
                      Positioned(
                        right: 20,
                        top: 20,
                        bottom: 20,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              offer['title'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              offer['highlight'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              offer['action'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? theme.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// A custom painter to draw subtle starburst rays
class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.2, size.height * 0.5);
    final path = Path();

    for (int i = 0; i < 36; i += 2) {
      final angle1 = i * 10 * 3.14159 / 180;
      final angle2 = (i + 1) * 10 * 3.14159 / 180;
      
      path.moveTo(center.dx, center.dy);
      path.lineTo(center.dx + 400 * 1, center.dy + 400 * angle1);
      path.lineTo(center.dx + 400 * 1, center.dy + 400 * angle2);
      path.close();
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
