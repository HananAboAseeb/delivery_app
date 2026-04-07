import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.walletBalance,
    super.walletId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['userName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phoneNumber'],
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      walletId: json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': name,
      'email': email,
      'phoneNumber': phone,
      'walletBalance': walletBalance,
      'walletId': walletId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? walletBalance,
    String? walletId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      walletBalance: walletBalance ?? this.walletBalance,
      walletId: walletId ?? this.walletId,
    );
  }
}
