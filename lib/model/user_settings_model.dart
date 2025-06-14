class UserSettings {
  final String name;
  final String email;
  final int height; // em cm
  final int weight; // em kg
  final Map<String, bool> dietaryPreferences;
  final int caloriesGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final bool notifyMealReminders;
  final bool notifyShoppingList;
  final bool notifyWeeklyReport;
  final String theme;

  UserSettings({
    required this.name,
    required this.email,
    this.height = 170,
    this.weight = 70,
    required this.dietaryPreferences,
    this.caloriesGoal = 2000,
    this.proteinGoal = 100,
    this.carbsGoal = 250,
    this.fatGoal = 65,
    this.notifyMealReminders = true,
    this.notifyShoppingList = true,
    this.notifyWeeklyReport = true,
    this.theme = 'Claro',
  });

  // Converter o objeto para um mapa (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'dietaryPreferences': dietaryPreferences,
      'caloriesGoal': caloriesGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'notifyMealReminders': notifyMealReminders,
      'notifyShoppingList': notifyShoppingList,
      'notifyWeeklyReport': notifyWeeklyReport,
      'theme': theme,
    };
  }

  // Criar um objeto a partir de um mapa (para recuperação de dados)
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    Map<String, bool> preferences = {};
    // Converter o mapa de preferências dietéticas
    if (map['dietaryPreferences'] != null) {
      Map<String, dynamic> preferencesMap = map['dietaryPreferences'];
      preferencesMap.forEach((key, value) {
        preferences[key] = value as bool;
      });
    }

    return UserSettings(
      name: map['name'] ?? 'Usuário',
      email: map['email'] ?? 'usuario@exemplo.com',
      height: map['height'] ?? 170,
      weight: map['weight'] ?? 70,
      dietaryPreferences: preferences,
      caloriesGoal: map['caloriesGoal'] ?? 2000,
      proteinGoal: map['proteinGoal'] ?? 100,
      carbsGoal: map['carbsGoal'] ?? 250,
      fatGoal: map['fatGoal'] ?? 65,
      notifyMealReminders: map['notifyMealReminders'] ?? true,
      notifyShoppingList: map['notifyShoppingList'] ?? true,
      notifyWeeklyReport: map['notifyWeeklyReport'] ?? true,
      theme: map['theme'] ?? 'Claro',
    );
  }

  // Valores padrão
  static UserSettings defaultSettings() {
    return UserSettings(
      name: 'Usuário',
      email: '',
      dietaryPreferences: {
        'Vegetariano': false,
        'Vegano': false,
        'Sem Glúten': false,
        'Sem Lactose': false,
        'Baixo Carboidrato': false,
        'Sem Açúcar': false,
      },
    );
  }

  // Criar uma cópia do objeto com algumas alterações
  UserSettings copyWith({
    String? name,
    String? email,
    int? height,
    int? weight,
    Map<String, bool>? dietaryPreferences,
    int? caloriesGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
    bool? notifyMealReminders,
    bool? notifyShoppingList,
    bool? notifyWeeklyReport,
    String? theme,
  }) {
    return UserSettings(
      name: name ?? this.name,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      notifyMealReminders: notifyMealReminders ?? this.notifyMealReminders,
      notifyShoppingList: notifyShoppingList ?? this.notifyShoppingList,
      notifyWeeklyReport: notifyWeeklyReport ?? this.notifyWeeklyReport,
      theme: theme ?? this.theme,
    );
  }
}
