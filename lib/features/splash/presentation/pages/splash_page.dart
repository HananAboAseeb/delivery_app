import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_store/core/theme/theme_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 1. تحميل الثيم المحفوظ 
    context.read<ThemeCubit>().loadTheme();
    
    // 2. الانتظار ثانيتين ثم اتخاذ القرار
    _startSplashLogic();
  }

  Future<void> _startSplashLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final hasSeenOnboarding = await storage.read(key: 'hasSeenOnboarding');

    if (!mounted) return;

    if (hasSeenOnboarding == 'true') {
      // Forcing the login page to appear first, skipping auto-login as requested
      context.read<AuthBloc>().add(LogoutEvent()); // Clean any stale cache
      context.go('/login');
    } else {
      // أول مرة يفتح التطبيق -> اذهب إلى شاشة الترحيب
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ThemeCubit, ThemeState>(
          listener: (context, state) {
            // الثيم تم تحميله (سيتكفل الـ MaterialApp بتحديث الألوان داخلياً)
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // بعد التحقق من حالة المصادقة
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is AuthUnauthenticated || state is AuthError) {
              context.go('/login');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار (مؤقتاً نعرض أيقونة إذا لم تتوفر الصورة بعد)
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.delivery_dining,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
