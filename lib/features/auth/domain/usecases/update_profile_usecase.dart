import 'package:my_store/core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<UserEntity> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.user);
  }
}

class UpdateProfileParams extends Equatable {
  final UserEntity user;

  const UpdateProfileParams({required this.user});

  @override
  List<Object?> get props => [user];
}
