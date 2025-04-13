import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class MealController with ChangeNotifier {
  static const String _storageKey = 'meals';

  final StorageService _storageService;
  List<Meal> _meals = [];

  MealController(this._storageService) {
    _loadMeals();
  }

  List<Meal> get meals => _meals;

  // Obter refeições para um dia específico
  List<Meal> getMealsForDay(DateTime date) {
    return _meals.where((meal) {
      return meal.date.year == date.year &&
          meal.date.month == date.month &&
          meal.date.day == date.day;
    }).toList();
  }

  // Obter refeições por tipo
  List<Meal> getMealsByType(String type) {
    return _meals.where((meal) => meal.name == type).toList();
  }

  // Calcular estatísticas nutricionais para um dia específico
  Map<String, int> getNutritionStatsForDay(DateTime date) {
    final mealsForDay = getMealsForDay(date);

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (var meal in mealsForDay) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  // Carregar refeições do armazenamento
  Future<void> _loadMeals() async {
    if (_storageService.hasKey(_storageKey)) {
      final mealsData = _storageService.getList(_storageKey);
      if (mealsData != null) {
        _meals = mealsData.map((data) => Meal.fromMap(data)).toList();
        notifyListeners();
      }
    } else {
      // Adicionar dados de exemplo
      _addSampleData();
    }
  }

  // Adicionar dados de exemplo
  Future<void> _addSampleData() async {
    final now = DateTime.now();

    _meals = [
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Café da Manhã',
        description: 'Aveia com frutas e mel',
        calories: 320,
        protein: 12,
        carbs: 45,
        fat: 8,
        rating: 4,
        difficulty: 'Fácil',
        prepTime: 10,
        ingredients: ['Aveia', 'Banana', 'Mel', 'Canela'],
        instructions: 'Misture todos os ingredientes e sirva.',
        time: '07:00',
      ),
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Almoço',
        description: 'Salada com frango grelhado',
        calories: 480,
        protein: 35,
        carbs: 25,
        fat: 15,
        rating: 5,
        difficulty: 'Médio',
        prepTime: 30,
        ingredients: ['Peito de frango', 'Alface', 'Tomate', 'Azeite', 'Sal'],
        instructions: 'Grelhe o frango e misture com os vegetais.',
        time: '12:00',
      ),
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Lanche',
        description: 'Iogurte com granola',
        calories: 180,
        protein: 8,
        carbs: 20,
        fat: 5,
        rating: 5,
        difficulty: 'Fácil',
        prepTime: 3,
        ingredients: ['Iogurte natural', 'Granola', 'Frutas vermelhas'],
        instructions: 'Misture todos os ingredientes e sirva.',
        time: '16:00',
      ),
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Jantar',
        description: 'Sopa de legumes',
        calories: 250,
        protein: 10,
        carbs: 30,
        fat: 6,
        rating: 4,
        difficulty: 'Médio',
        prepTime: 40,
        ingredients: [
          'Batata',
          'Cenoura',
          'Cebola',
          'Abobrinha',
          'Sal',
          'Azeite',
        ],
        instructions: 'Cozinhe todos os legumes e bata no liquidificador.',
        time: '20:00',
      ),
    ];

    await _saveMeals();
  }

  // Adicionar uma nova refeição
  Future<void> addMeal(Meal meal) async {
    _meals.add(meal);
    await _saveMeals();
    notifyListeners();
  }

  // Atualizar uma refeição existente
  Future<void> updateMeal(Meal updatedMeal) async {
    final index = _meals.indexWhere((meal) => meal.id == updatedMeal.id);
    if (index != -1) {
      _meals[index] = updatedMeal;
      await _saveMeals();
      notifyListeners();
    }
  }

  // Excluir uma refeição
  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((meal) => meal.id == id);
    await _saveMeals();
    notifyListeners();
  }

  // Avaliar uma refeição
  Future<void> rateMeal(String id, int rating) async {
    final index = _meals.indexWhere((meal) => meal.id == id);
    if (index != -1) {
      final updatedMeal = _meals[index].copyWith(rating: rating);
      _meals[index] = updatedMeal;
      await _saveMeals();
      notifyListeners();
    }
  }

  // Salvar refeições no armazenamento
  Future<void> _saveMeals() async {
    final List<Map<String, dynamic>> mealsData =
        _meals.map((meal) => meal.toMap()).toList();
    await _storageService.saveList(_storageKey, mealsData);
  }
}
