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

  // Modern Split-style cards with fresh beautiful vibrant photos and realistic promotional text
  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'طازج وسريع',
      'highlight': 'خصم 30%',
      'action': 'على أول طلب لك من قسم اللحوم والخضار',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=600&q=80', // Vibrant groceries and greens
    },
    {
      'title': 'ألذ الوجبات',
      'highlight': 'توصيل مجاني',
      'action': 'أطلب من مطعمك المفضل بضغطة زر',
      'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=600&q=80', // Vibrant hot meal details
    },
    {
      'title': 'مقاضي البيت',
      'highlight': 'لباب بيتك',
      'action': 'كل ما يحتاجه منزلك نوفره لك في أسرع وقت',
      'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=600&q=80', // Colorful supermarket
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // 1. Full Background Real Image (Completly pure original colors!)
                      Positioned.fill(
                        child: Image.network(
                          offer['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // 2. Crisp Typography with Cinematic Text-Shadows 
                      // This avoids ANY colored tint entirely on the image, perfectly preserving the photo 
                      // while making the white text pop phenomenally well securely!
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
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                                  Shadow(color: Colors.black54, blurRadius: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              offer['highlight'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
                                  Shadow(color: Colors.black87, blurRadius: 15),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              offer['action'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                                ],
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
