import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_store/features/auth/logic/auth_bloc.dart';
import 'package:my_store/core/theme/theme_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ThemeCubit>().loadTheme();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _startSplashLogic();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startSplashLogic() async {
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final hasSeenOnboarding = await storage.read(key: 'hasSeenOnboarding');

    if (!mounted) return;

    if (hasSeenOnboarding == 'true') {
      context.read<AuthBloc>().add(LogoutEvent());
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ThemeCubit, ThemeState>(listener: (context, state) {}),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is AuthUnauthenticated || state is AuthError) {
              context.go('/login');
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF3E0), // orange 50 - Very light
                  Color(0xFFFFE0B2), // orange 100
                  Color(0xFFFFB74D), // orange 300
                  Color(0xFFE65100), // Primary Color - exactly matching app theme
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // --- Lottie Animation (No white circle) ---
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Lottie.asset(
                            'assets/animation/delivery.json',
                            width: 220,
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.electric_moped_rounded,
                                size: 120,
                                color: Color(0xFFE65100),
                              );
                            },
                          ),
                        ),

                        // Decreased distance based on user suggestion
                        const SizedBox(height: 24),

                        // --- App Name & Tagline (Fade + Slide In) ---
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'خلك مرتاح',
                                  style: GoogleFonts.cairo(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'كل مقاضيك تصل لباب بيتك',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // --- Loading Indicator ---
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 48.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'جاري التحميل...',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}
