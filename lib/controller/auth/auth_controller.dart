import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/controller/settings/user_settings_controller.dart';
import 'package:pdm_fatec_1/controller/shopping_list/shopping_list_controller.dart';
import 'package:pdm_fatec_1/model/auth_model.dart';
import 'package:pdm_fatec_1/services/auth_service.dart';
import 'package:pdm_fatec_1/services/firestore_service.dart';
import 'package:pdm_fatec_1/services/service_locator.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class AuthController with ChangeNotifier {
  static const String _storageKey = 'current_user';

  final StorageService _storageService;
  final AuthService _authService;
  final FirestoreService _firestoreService;

  firebase_auth.User? _firebaseUser;
  User _currentUser = User.guest();
  String? _error;
  bool _isLoading = false;

  AuthController(
    this._storageService,
    this._authService,
    this._firestoreService,
  ) {
    _init();
  }

  User get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser.isAuthenticated;
  String? get error => _error;
  bool get isLoading => _isLoading;

  void _init() {
    _authService.authStateChanges.listen((firebase_auth.User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _currentUser = User(
          id: user.uid,
          name: user.displayName ?? 'Usuário',
          email: user.email ?? '',
          isAuthenticated: true,
        );
        // Carregar dados do Firestore quando o usuário fizer login
        await _loadUserData();
        // Configurar ID do usuário nos outros controllers
        _setupUserControllers(user.uid);
      } else {
        _currentUser = User.guest();
        // Limpar ID do usuário nos outros controllers
        _clearUserControllers();
      }
      notifyListeners();
    });
  }

  void _setupUserControllers(String userId) {
    getIt<MealController>().setUserId(userId);
    getIt<ShoppingListController>().setUserId(userId);
    getIt<UserSettingsController>().setUserId(userId);
  }

  void _clearUserControllers() {
    getIt<MealController>().setUserId(null);
    getIt<ShoppingListController>().setUserId(null);
    getIt<UserSettingsController>().setUserId(null);
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser != null) {
      try {
        // Carregar perfil do usuário
        final userProfile = await _firestoreService.getUserProfile(
          _firebaseUser!.uid,
        );

        if (userProfile != null) {
          _currentUser = User.fromMap(userProfile);

          // Atualizar nome e email do usuário no UserSettingsController
          final userSettingsController = getIt<UserSettingsController>();
          await userSettingsController.updateName(_currentUser.name);
          await userSettingsController.updateEmail(_currentUser.email);

          notifyListeners();
        } else {
          // Se não encontrar o perfil, criar um novo com os dados do Auth
          final user = User(
            id: _firebaseUser!.uid,
            email: _firebaseUser!.email ?? '',
            name: _firebaseUser!.displayName ?? 'Usuário',
            isAuthenticated: true,
          );

          await _firestoreService.createUserProfile(_firebaseUser!);
          _currentUser = user;

          // Atualizar nome e email do usuário no UserSettingsController
          final userSettingsController = getIt<UserSettingsController>();
          await userSettingsController.updateName(user.name);
          await userSettingsController.updateEmail(user.email);

          notifyListeners();
        }
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
        // Em caso de erro, usar dados básicos do Auth
        _currentUser = User(
          id: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          name: _firebaseUser!.displayName ?? 'Usuário',
          isAuthenticated: true,
        );
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Atualizar o nome do usuário no Firebase Auth
        await userCredential.user!.updateDisplayName(name);

        // Criar perfil do usuário no Firestore
        await _firestoreService.createUserProfile(userCredential.user!);

        // Atualizar o nome no UserSettingsController
        final userSettingsController = getIt<UserSettingsController>();
        await userSettingsController.updateName(name);

        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = User.guest();
      _clearUserControllers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    return _firebaseUser != null;
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
