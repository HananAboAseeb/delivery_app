import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingItem {
  final String imagePath;
  final String title1;
  final String titleHighlight;
  final String title2;
  final String description;

  OnboardingItem({
    required this.imagePath,
    required this.title1,
    required this.titleHighlight,
    required this.title2,
    required this.description,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _data = [
    OnboardingItem(
      imagePath: "assets/images/onboarding_groceries.png",
      title1: "كل ",
      titleHighlight: "احتياجاتك",
      title2: "\nفي تطبيق واحد",
      description: "الوجبات الشهية ومقاضي البيت اليومية،\nبين يديك في أي وقت وبكل سهولة.",
    ),
    OnboardingItem(
      imagePath: "assets/images/onboarding_delivery.png",
      title1: "توصيل ",
      titleHighlight: "سريع ",
      title2: "\nوتتبع مباشر",
      description: "اطلب وتتبع طلبك خطوة بخطوة\nمن متجرك المفضل إليك بكل شفافية.",
    ),
    OnboardingItem(
      imagePath: "assets/images/onboarding_wallet.png",
      title1: "محفظة ",
      titleHighlight: "ذكية ",
      title2: "\nودفع مرن",
      description: "خيارات دفع تناسبك، اشحن محفظتك،\nأو ادفع بالبطاقة، أو نقداً عند الاستلام.",
    ),
  ];

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'hasSeenOnboarding', value: 'true');
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage == _data.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Override the primary color to a rich vibrant orange as requested
    final primaryColor = const Color(0xFFE65100); 

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, 
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 24.0),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                    ),
                    child: Text(
                      "تخطي",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.blueGrey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Local Assets Generated Extremely High Quality
                        Expanded(
                          flex: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Hero(
                              tag: 'img_hero_$index',
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        
                        Expanded(
                          flex: 45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                // Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _data.length,
                                    (dotIndex) => _buildIndicator(dotIndex, primaryColor),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Title (RichText dual color)
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.tajawal(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E1E1E),
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(text: item.title1),
                                      TextSpan(
                                        text: item.titleHighlight,
                                        style: TextStyle(color: primaryColor),
                                      ),
                                      TextSpan(text: item.title2),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Description
                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: const Color(0xFF757575),
                                    fontWeight: FontWeight.w600,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ); 
                  },
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0, left: 32, right: 32),
                child: InkWell(
                  onTap: _nextPage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // Button Text Animation
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: Text(
                        _currentPage == _data.length - 1 ? "ابدأ تجربتك" : "التالي",
                        key: ValueKey<int>(_currentPage),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, Color primaryColor) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 5,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
