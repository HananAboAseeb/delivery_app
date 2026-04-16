import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth_bloc.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
             String errorMsg = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً';
             final rawMsg = state.message.toLowerCase();
             
             // Advanced robust parsing to strictly enforce error categories
             if (rawMsg.contains('401') || rawMsg.contains('unauthorized') || rawMsg.contains('400') || rawMsg.contains('bad request')) {
                // Typical API rejection for wrong User/Pass
                errorMsg = 'تأكد من صحة اسم المستخدم أو كلمة المرور';
             } else if (rawMsg.contains('404')) {
                errorMsg = 'اسم المستخدم غير موجود لدينا';
             } else if (rawMsg.contains('socketexception') || rawMsg.contains('handshake') || rawMsg.contains('os error') || rawMsg.contains('timeout')) {
                // Accurate detection of zero-internet connection drops (avoiding generic words)
                errorMsg = 'لا يوجد اتصال بالإنترنت، يرجى تفعيل الشبكة والمحاولة مجدداً';
             } else if (rawMsg.contains('server') || rawMsg.contains('500')) {
                errorMsg = 'يوجد ضغط أو مشكلة مؤقتة في الخادم، جرب لاحقاً';
             } else {
                errorMsg = 'تأكد من صحة البيانات أو من استقرار الاتصال';
             }
             
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Row(
                    children: [
                       const Icon(Icons.error_outline_rounded, color: Colors.white, size: 28),
                       const SizedBox(width: 12),
                       Expanded(child: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                    ],
                 ),
                 backgroundColor: Colors.red.shade700,
                 behavior: SnackBarBehavior.floating,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 duration: const Duration(seconds: 4),
               ),
             );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // --- Background Image with Gradient Fade ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.45,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/delivery_header.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.8),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // --- Main Scrollable Content ---
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: size.height * 0.15),

                        // --- Titles ---
                        const Text(
                          'مرحباً بعودتك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'الرجاء إدخال بياناتك للوصول إلى حسابك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Divider(color: Colors.grey.shade200, thickness: 1),
                        const SizedBox(height: 24),

                        // --- Username Input ---
                        _buildLabel('اسم المستخدم'),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'ادخل اسم المستخدم', 
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),

                        // --- Password Input ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('كلمة المرور'),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'الرجاء إدخال كلمة المرور';
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // --- Login Button ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Pill shape
                            ),
                            elevation: 8,
                            shadowColor: theme.primaryColor.withOpacity(0.5),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          LoginEvent(_emailController.text,
                                              _passwordController.text),
                                        );
                                  }
                                },
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),

                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: const Text('ليس لديك حساب؟ إنشاء حساب جديد', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),

                        const SizedBox(height: 16),

                        // --- Guest Login Button (Disabled for security) ---
                        OutlinedButton.icon(
                          onPressed: null, // Disabled for security
                          icon: Icon(Icons.person_pin_circle_rounded, color: Colors.grey.shade400),
                          label: const Text(
                            'الدخول كزائر',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
