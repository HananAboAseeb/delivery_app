import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth_bloc.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedCountryCode = '+967'; // Default Yemen

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم إنشاء الحساب وتسجيل الدخول بنجاح!'),
                  backgroundColor: Colors.green),
            );
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
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
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.adjust_rounded,
                                color: theme.primaryColor, size: 28),
                            const SizedBox(width: 8),
                            const Text(
                              'WASL',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.12),

                        const Text(
                          'إنشاء حساب جديد',
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
                            'الرجاء إدخال بياناتك للتسجيل في النظام',
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

                        // --- Name Input ---
                        _buildLabel('اسم المستخدم (أو الاسم الكامل)'),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'أحمد محمد',
                          prefixIcon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'الرجاء إدخال الاسم';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Phone Input with Country Code ---
                        _buildLabel('رقم الهاتف'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCountryCode,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.grey),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 16),
                                    items: const [
                                      DropdownMenuItem(
                                          value: '+967',
                                          child: Text('🇾🇪 +967')),
                                      DropdownMenuItem(
                                          value: '+966',
                                          child: Text('🇸🇦 +966')),
                                      DropdownMenuItem(
                                          value: '+971',
                                          child: Text('🇦🇪 +971')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(
                                            () => _selectedCountryCode = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomTextField(
                                controller: _phoneController,
                                labelText: '77xxxxxxx',
                                prefixIcon: Icons.phone_android_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'الرجاء إدخال رقم الهاتف';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Password Input ---
                        _buildLabel('كلمة المرور'),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'الرجاء إدخال كلمة المرور';
                            if (v.length < 6)
                              return 'يجب أن تكون 6 أحرف على الأقل';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Confirm Password Input ---
                        _buildLabel('تأكيد كلمة المرور'),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'الرجاء تأكيد كلمة المرور';
                            if (v != _passwordController.text)
                              return 'الرقم السري غير متطابق';
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // --- Register Button ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: theme.primaryColor.withOpacity(0.5),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final fullPhone = _selectedCountryCode +
                                        _phoneController.text.trim();
                                    context.read<AuthBloc>().add(
                                          RegisterEvent(
                                            _nameController.text.trim(),
                                            '', // Empty email
                                            fullPhone,
                                            _passwordController.text,
                                          ),
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
                                  'إنشاء حساب',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('لدي حساب بالفعل؟ تسجيل الدخول'),
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
