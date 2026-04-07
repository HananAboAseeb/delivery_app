import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "All Your Needs, One App",
      "description": "From gourmet meals to daily groceries, delivered instantly.",
      "image": "https://cdn-icons-png.flaticon.com/512/1046/1046784.png" // صورة توصيل عامة
    },
    {
      "title": "Fast & Trackable Delivery",
      "description": "Real-time updates from store to door. Your curated essentials are always within sight.",
      "image": "https://cdn-icons-png.flaticon.com/512/190/190411.png" // صورة رجل التوصيل
    },
    {
      "title": "Smart Wallet & Easy Payments",
      "description": "Securely store funds in your app wallet for faster checkouts. Pay with cards or cash on delivery.",
      "image": "https://cdn-icons-png.flaticon.com/512/6335/6335800.png" // صورة محفظة
    },
  ];

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'hasSeenOnboarding', value: 'true');
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(
                    image: _onboardingData[index]["image"]!,
                    title: _onboardingData[index]["title"]!,
                    description: _onboardingData[index]["description"]!,
                  );
                },
              ),
            ),
            
            // البار السفلي للتحكم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زِر Skip يظهر فقط في الصفحات الأولى
                  _currentPage != _onboardingData.length - 1
                      ? TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        )
                      : const SizedBox(width: 60), // فضاء وهمي للحفاظ على المحاذاة

                  // مؤشرات الصفحات (Dots)
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),

                  // زر Next أو Get Started
                  _currentPage == _onboardingData.length - 1
                      ? ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Get Started", style: TextStyle(color: Colors.white)),
                        )
                      : TextButton(
                          onPressed: _nextPage,
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.network(
            image,
            height: 250,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 200,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
