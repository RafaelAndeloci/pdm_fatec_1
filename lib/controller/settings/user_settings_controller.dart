import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pdm_fatec_1/model/user_settings_model.dart';
import 'package:pdm_fatec_1/services/auth_service.dart';
import 'package:pdm_fatec_1/services/firestore_service.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class UserSettingsController with ChangeNotifier {
  static const String _storageKey = 'user_settings';

  final StorageService _storageService;
  final FirestoreService _firestoreService;
  UserSettings _settings = UserSettings.defaultSettings();
  String? _userId;
  StreamSubscription? _settingsSubscription;

  UserSettingsController(this._storageService, this._firestoreService) {
    _loadSettings();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  UserSettings get settings => _settings;

  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _settingsSubscription?.cancel();
      if (userId != null) {
        // Atualizar o email quando o usuário fizer login
        final authService = GetIt.I<AuthService>();
        final currentUser = authService.currentUser;
        if (currentUser != null) {
          _settings = _settings.copyWith(email: currentUser.email ?? '');
        }
      }
      _loadSettings();
    }
  }

  // Obter o nome do usuário
  String get userName => _settings.name;

  // Obter as preferências alimentares
  Map<String, bool> get dietaryPreferences => _settings.dietaryPreferences;

  // Obter as metas nutricionais
  Map<String, int> get nutritionalGoals => {
    'calories': _settings.caloriesGoal,
    'protein': _settings.proteinGoal,
    'carbs': _settings.carbsGoal,
    'fat': _settings.fatGoal,
  };

  // Carregar configurações do armazenamento
  Future<void> _loadSettings() async {
    if (_userId != null) {
      // Carregar do Firestore e escutar mudanças
      _settingsSubscription = _firestoreService
          .getUserSettingsStream(_userId!)
          .listen((settings) {
            if (settings != null) {
              // Manter o email atual se não houver um no Firestore
              final currentEmail = _settings.email;
              _settings = settings;
              if (settings.email.isEmpty && currentEmail.isNotEmpty) {
                _settings = _settings.copyWith(email: currentEmail);
              }
              notifyListeners();
            }
          });
    } else if (_storageService.hasKey(_storageKey)) {
      // Carregar do armazenamento local
      final settingsData = _storageService.getData(_storageKey);
      if (settingsData != null) {
        _settings = UserSettings.fromMap(settingsData);
        notifyListeners();
      }
    }
  }

  // Atualizar configurações
  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, newSettings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar nome
  Future<void> updateName(String name) async {
    _settings = _settings.copyWith(name: name);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar email
  Future<void> updateEmail(String email) async {
    _settings = _settings.copyWith(email: email);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar altura
  Future<void> updateHeight(int height) async {
    _settings = _settings.copyWith(height: height);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar peso
  Future<void> updateWeight(int weight) async {
    _settings = _settings.copyWith(weight: weight);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar preferências alimentares
  Future<void> updateDietaryPreferences(Map<String, bool> preferences) async {
    _settings = _settings.copyWith(dietaryPreferences: preferences);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar metas de nutrientes
  Future<void> updateNutritionGoals({
    int? caloriesGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
  }) async {
    _settings = _settings.copyWith(
      caloriesGoal: caloriesGoal,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
    );
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar configurações de notificação
  Future<void> updateNotificationSettings({
    bool? notifyMealReminders,
    bool? notifyShoppingList,
    bool? notifyWeeklyReport,
  }) async {
    _settings = _settings.copyWith(
      notifyMealReminders: notifyMealReminders,
      notifyShoppingList: notifyShoppingList,
      notifyWeeklyReport: notifyWeeklyReport,
    );
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Atualizar tema
  Future<void> updateTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }

  // Salvar configurações no armazenamento local
  Future<void> _saveSettings() async {
    await _storageService.saveData(_storageKey, _settings.toMap());
  }

  // Redefinir configurações para os valores padrão
  Future<void> resetToDefaults() async {
    _settings = UserSettings.defaultSettings();
    if (_userId != null) {
      await _firestoreService.saveUserSettings(_userId!, _settings);
    } else {
      await _saveSettings();
    }
    notifyListeners();
  }
}
