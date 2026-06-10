import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthProvider({required this.loginUser, required this.registerUser});

  UserEntity? _user;
  bool _isLoading = false;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await loginUser(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, {String? name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await registerUser(email, password, name: name);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    if (_user == null) throw Exception("User not logged in");

    _isLoading = true;
    notifyListeners();

    try {
      await loginUser.repository.updateUserProfile(
        _user!.uid,
        name: name,
        avatarUrl: avatarUrl,
      );

      // Update local user object
      _user = UserEntity(
        uid: _user!.uid,
        email: _user!.email,
        role: _user!.role,
        name: name ?? _user!.name,
        avatarUrl: avatarUrl ?? _user!.avatarUrl,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
