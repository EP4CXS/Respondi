import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

class AuthController extends ChangeNotifier {
  AuthController()
      : _loginUseCase = LoginUseCase(AuthRepositoryImpl()),
        _registerUseCase = RegisterUseCase(AuthRepositoryImpl()),
        _googleSignInUseCase = GoogleSignInUseCase(AuthRepositoryImpl());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
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
    try {
      currentUser = await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      errorMessage = null;
      debugPrint('Login success: ${currentUser?.email}');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    try {
      currentUser = await _registerUseCase(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      errorMessage = null;
      debugPrint('Register success: ${currentUser?.email}');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      currentUser = await _googleSignInUseCase();
      errorMessage = null;
      debugPrint('Google sign-in success: ${currentUser?.email}');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearAuthFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    confirmPasswordController.clear();
    errorMessage = null;
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
