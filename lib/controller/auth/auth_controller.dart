import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/auth_model.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class AuthController with ChangeNotifier {
  static const String _storageKey = 'current_user';

  final StorageService _storageService;
  User _currentUser = User.guest();

  AuthController(this._storageService) {
    _loadUser();
  }

  User get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser.isAuthenticated;

  // Carregar usuário do armazenamento
  Future<void> _loadUser() async {
    if (_storageService.hasKey(_storageKey)) {
      final userData = _storageService.getData(_storageKey);
      if (userData != null) {
        _currentUser = User.fromMap(userData);
        notifyListeners();
      }
    }
  }

  // Simular login
  Future<bool> login(String email, String password) async {
    // Em um app real, você faria uma chamada de API aqui
    // Por enquanto, vamos apenas simular um login bem-sucedido

    // Simulando verificação de credenciais
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: 'user1',
        name: 'Usuário',
        email: email,
        isAuthenticated: true,
      );

      await _storageService.saveData(_storageKey, _currentUser.toMap());
      notifyListeners();
      return true;
    }

    return false;
  }

  // Simular registro
  Future<bool> register(String name, String email, String password) async {
    // Em um app real, você faria uma chamada de API aqui

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: 'user1',
        name: name,
        email: email,
        isAuthenticated: true,
      );

      await _storageService.saveData(_storageKey, _currentUser.toMap());
      notifyListeners();
      return true;
    }

    return false;
  }

  // Fazer logout
  Future<void> logout() async {
    _currentUser = User.guest();
    await _storageService.removeData(_storageKey);
    notifyListeners();
  }

  // Verificar se o usuário está logado
  Future<bool> checkAuthStatus() async {
    await _loadUser();
    return isAuthenticated;
  }
}
