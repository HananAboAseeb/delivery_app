import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
  });

  factory UserProfile.defaults() => const UserProfile(
        name: 'أحمد',
        email: 'ahmed@example.com',
        phone: '0500000000',
        avatarUrl: '',
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [name, email, phone, avatarUrl];
}

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileSaving extends ProfileState {
  final UserProfile profile;
  const ProfileSaving(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileSaved extends ProfileState {
  final UserProfile profile;
  const ProfileSaved(this.profile);
  @override
  List<Object?> get props => [profile];
}
