import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'package:my_store/features/address/presentation/pages/address_page.dart';

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

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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

          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                title: const Text('حسابي', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(profile.avatarUrl),
                          onBackgroundImageError: (_, __) {},
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0] : 'أ',
                            style: TextStyle(fontSize: 36, color: theme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(profile.email, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu Items
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'بياناتي',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileCubit>(),
                            child: const EditProfilePage(),
                          ),
                        ));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'عناويني',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressPage()));
                      },
                    ),
                    _buildMenuItem(context, icon: Icons.payment_outlined, title: 'طرق الدفع', onTap: () {}),
                    _buildMenuItem(context, icon: Icons.notifications_outlined, title: 'الإشعارات', onTap: () {}),
                    _buildMenuItem(context, icon: Icons.settings_outlined, title: 'الإعدادات', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'تسجيل خروج',
                      isDestructive: true,
                      onTap: () async {
                        // Clear profile cache
                        await context.read<ProfileCubit>().clearProfile();
                        // Clear access token
                        const storage = FlutterSecureStorage();
                        await storage.delete(key: 'access_token');
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : theme.primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        trailing: isDestructive ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Edit Profile Page
// ─────────────────────────────────────────────────────────────
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill from current cubit state
    final state = context.read<ProfileCubit>().state;
    final profile = state is ProfileLoaded ? state.profile : UserProfile.defaults();
    _nameCtrl = TextEditingController(text: profile.name);
    _emailCtrl = TextEditingController(text: profile.email);
    _phoneCtrl = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تعديل بياناتي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('تم حفظ البيانات بنجاح'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, size: 60, color: theme.primaryColor),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Name
                _buildField(label: 'الاسم الكامل', controller: _nameCtrl, icon: Icons.person_outline),
                const SizedBox(height: 16),

                // Email
                _buildField(label: 'البريد الإلكتروني', controller: _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // Phone
                _buildField(label: 'رقم الهاتف', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            context.read<ProfileCubit>().saveProfile(
                                  name: _nameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('حفظ التغييرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
