import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/user_settings_model.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class UserSettingsController with ChangeNotifier {
  static const String _storageKey = 'user_settings';

  final StorageService _storageService;
  UserSettings _settings = UserSettings.defaultSettings();

  UserSettingsController(this._storageService) {
    _loadSettings();
  }

  UserSettings get settings => _settings;

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
    if (_storageService.hasKey(_storageKey)) {
      final settingsData = _storageService.getData(_storageKey);
      if (settingsData != null) {
        _settings = UserSettings.fromMap(settingsData);
        notifyListeners();
      }
    }
  }

  // Atualizar o nome do usuário
  Future<void> updateName(String name) async {
    _settings = _settings.copyWith(name: name);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar o email
  Future<void> updateEmail(String email) async {
    _settings = _settings.copyWith(email: email);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar a altura
  Future<void> updateHeight(int height) async {
    _settings = _settings.copyWith(height: height);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar o peso
  Future<void> updateWeight(int weight) async {
    _settings = _settings.copyWith(weight: weight);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar uma preferência alimentar
  Future<void> updateDietaryPreference(String preference, bool value) async {
    final updatedPreferences = Map<String, bool>.from(
      _settings.dietaryPreferences,
    );
    updatedPreferences[preference] = value;

    _settings = _settings.copyWith(dietaryPreferences: updatedPreferences);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar todas as metas nutricionais
  Future<void> updateNutritionalGoals({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    _settings = _settings.copyWith(
      caloriesGoal: calories,
      proteinGoal: protein,
      carbsGoal: carbs,
      fatGoal: fat,
    );
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar as configurações de notificação
  Future<void> updateNotificationSettings({
    required bool mealReminders,
    required bool shoppingList,
    required bool weeklyReport,
  }) async {
    _settings = _settings.copyWith(
      notifyMealReminders: mealReminders,
      notifyShoppingList: shoppingList,
      notifyWeeklyReport: weeklyReport,
    );
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar o tema do aplicativo
  Future<void> updateTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _saveSettings();
    notifyListeners();
  }

  // Atualizar todas as configurações do usuário
  Future<void> updateAllSettings(UserSettings settings) async {
    _settings = settings;
    await _saveSettings();
    notifyListeners();
  }

  // Salvar configurações no armazenamento
  Future<void> _saveSettings() async {
    await _storageService.saveData(_storageKey, _settings.toMap());
  }

  // Redefinir configurações para os valores padrão
  Future<void> resetToDefaults() async {
    _settings = UserSettings.defaultSettings();
    await _saveSettings();
    notifyListeners();
  }
}
