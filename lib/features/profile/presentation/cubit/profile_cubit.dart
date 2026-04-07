import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/service_locator.dart' as di;
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FlutterSecureStorage _storage;

  static const _keyName   = 'profile_name';
  static const _keyEmail  = 'profile_email';
  static const _keyPhone  = 'profile_phone';
  static const _keyAvatar = 'profile_avatar';

  ProfileCubit(this._storage) : super(ProfileLoading()) {
    loadProfile();
  }

  /// Called on every page open – reads the locally cached profile (which was
  /// populated during login) and shows it immediately.  Then silently refreshes
  /// from the API in the background.
  Future<void> loadProfile() async {
    emit(ProfileLoading());

    // ── 1. Read from local cache (fast, always works offline) ──────────────
    final name   = await _storage.read(key: _keyName);
    final email  = await _storage.read(key: _keyEmail);
    final phone  = await _storage.read(key: _keyPhone);
    final avatar = await _storage.read(key: _keyAvatar);

    var profile = UserProfile(
      name:      name   ?? '',
      email:     email  ?? '',
      phone:     phone  ?? '',
      avatarUrl: avatar ?? 'https://i.pravatar.cc/150',
    );

    emit(ProfileLoaded(profile));

    // ── 2. Background refresh from API (updates the display if needed) ──────
    try {
      final apiClient = di.sl<ApiClient>();
      final response  = await apiClient.dio.get('/api/account/my-profile');
      final data      = response.data as Map<String, dynamic>?;

      if (data != null) {
        final freshName  = data['userName']    ?? data['name'] ?? profile.name;
        final freshEmail = data['email']        ?? profile.email;
        final freshPhone = data['phoneNumber']  ?? profile.phone;

        profile = profile.copyWith(
          name:  freshName,
          email: freshEmail,
          phone: freshPhone,
        );

        // Keep local cache in sync
        await _storage.write(key: _keyName,  value: freshName);
        await _storage.write(key: _keyEmail, value: freshEmail);
        await _storage.write(key: _keyPhone, value: freshPhone);

        emit(ProfileLoaded(profile));
      }
    } catch (_) {
      // Network error – we already emitted the cached version, so do nothing
    }
  }

  /// Saves the profile both to the API and to local cache.
  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    final current = (state is ProfileLoaded)
        ? (state as ProfileLoaded).profile
        : UserProfile(name: name, email: email, phone: phone, avatarUrl: avatarUrl ?? 'https://i.pravatar.cc/150');

    final updated = current.copyWith(
      name:      name,
      email:     email,
      phone:     phone,
      avatarUrl: avatarUrl,
    );

    emit(ProfileSaving(updated));

    try {
      // Push to API
      final apiClient = di.sl<ApiClient>();
      await apiClient.dio.put('/api/account/my-profile', data: {
        'userName':    updated.name,
        'email':       updated.email,
        'phoneNumber': updated.phone,
      });

      // Persist locally
      await _storage.write(key: _keyName,   value: updated.name);
      await _storage.write(key: _keyEmail,  value: updated.email);
      await _storage.write(key: _keyPhone,  value: updated.phone);
      await _storage.write(key: _keyAvatar, value: updated.avatarUrl);

      emit(ProfileSaved(updated));
      await Future.delayed(const Duration(milliseconds: 400));
      emit(ProfileLoaded(updated));
    } catch (_) {
      emit(ProfileLoaded(current)); // Rollback UI on error
    }
  }

  /// Clears all locally cached profile data (called during logout).
  Future<void> clearProfile() async {
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyAvatar);
    emit(ProfileLoaded(UserProfile(name: '', email: '', phone: '', avatarUrl: 'https://i.pravatar.cc/150')));
  }
}
