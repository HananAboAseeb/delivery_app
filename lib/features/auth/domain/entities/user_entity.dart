import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double walletBalance;
  final String? walletId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.walletBalance,
    this.walletId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        walletBalance,
        walletId,
      ];
}
