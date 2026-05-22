import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return AppUser(
      id: 'placeholder-id',
      fullName: 'User',
      email: email,
    );
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return AppUser(
      id: 'placeholder-id',
      fullName: fullName,
      email: email,
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const AppUser(
      id: 'google-placeholder-id',
      fullName: 'Google User',
      email: 'user@gmail.com',
    );
  }
}
