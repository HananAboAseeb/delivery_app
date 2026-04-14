import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';
import 'package:my_store/features/address/presentation/pages/address_page.dart';

import 'package:my_store/features/profile/presentation/widgets/profile_header.dart';
import 'package:my_store/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:my_store/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(const FlutterSecureStorage()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  void _showThemeColorEditor(BuildContext context, ThemeData theme) {
    String newColor = '#66adde';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تخصيص ألوان التطبيق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'بصفتك مشرفاً، يمكنك تغيير اللون الأساسي للتطبيق (يجب عمل Hot Restart بعد التعديل لتطبيقه بالكامل).'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'كود اللون (مثال #66ADDE)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  newColor = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حفظ اللون $newColor مبدئياً')),
                );
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = switch (state) {
            ProfileLoaded(:final profile) => profile,
            ProfileSaving(:final profile) => profile,
            ProfileSaved(:final profile) => profile,
            _ => UserProfile.defaults(),
          };

          final isAdmin = profile.name.toLowerCase() == 'admin' ||
              profile.email.toLowerCase() == 'admin';

          return CustomScrollView(
            slivers: [
              ProfileHeader(
                  name: profile.name,
                  email: profile.email,
                  avatarUrl: profile.avatarUrl),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('إعدادات الحساب',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700)),
                    const SizedBox(height: 16),
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'بياناتي الشخصية',
                      subtitle: 'تعديل اسمك وبريدك الإلكتروني',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileCubit>(),
                                child: const EditProfilePage(),
                              ),
                            ));
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'عناويني المحفوظة',
                      subtitle: 'إدارة وتعديل عناوين التوصيل',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddressPage()));
                      },
                    ),
                    ProfileMenuItem(
                        icon: Icons.payment_outlined,
                        title: 'طرق الدفع',
                        subtitle: 'إضافة وتعديل البطاقات',
                        onTap: () {}),
                    const SizedBox(height: 24),
                    Text('إعدادات عامة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700)),
                    const SizedBox(height: 16),
                    ProfileMenuItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'الإشعارات',
                        onTap: () {}),
                    ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'إعدادات التطبيق',
                        onTap: () {}),
                    if (isAdmin) ...[
                      const SizedBox(height: 24),
                      Text('صلاحيات المشرف',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700)),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.color_lens_outlined,
                        title: 'تخصيص ألوان التطبيق',
                        subtitle: 'ميزة خاصة بمدير النظام',
                        onTap: () => _showThemeColorEditor(context, theme),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'تسجيل الخروج من الحساب',
                      isDestructive: true,
                      onTap: () async {
                        await context.read<ProfileCubit>().clearProfile();
                        const storage = FlutterSecureStorage();
                        await storage.delete(key: 'access_token');
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
