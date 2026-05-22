import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? AuthLocalDataSource();

  final AuthLocalDataSource _localDataSource;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _localDataSource.login(email: email, password: password);
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _localDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
