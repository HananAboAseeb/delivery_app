import 'package:my_store/core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) async {
    return await repository.register(params.name, params.email, params.phone, params.password);
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterParams({required this.name, required this.email, required this.phone, required this.password});

  @override
  List<Object?> get props => [name, email, phone, password];
}
