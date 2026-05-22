import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository}) {
    final repo = repository ?? AuthRepositoryImpl();
    _loginUseCase = LoginUseCase(repo);
    _registerUseCase = RegisterUseCase(repo);
  }

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  AppUser? currentUser;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    errorMessage = null;
    try {
      currentUser = await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      debugPrint('Login success: ${currentUser?.email}');
    } catch (e) {
      errorMessage = _mapError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    errorMessage = null;
    successMessage = null;
    try {
      currentUser = await _registerUseCase(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (kIsWeb) {
        debugPrint(
          'Register success: ${currentUser?.email} '
          '(stored in browser — not the Windows respondi.db file)',
        );
      } else {
        debugPrint('Register success: ${currentUser?.email}');
      }
      successMessage = 'Account created and saved to the app database.';
    } catch (e) {
      errorMessage = _mapError(e);
    } finally {
      _setLoading(false);
    }
  }

  String _mapError(Object e) {
    if (e is AuthFailure) return e.message;
    return e.toString();
  }

  void clearAuthFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    confirmPasswordController.clear();
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
