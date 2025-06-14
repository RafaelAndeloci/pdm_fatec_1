import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:pdm_fatec_1/services/firestore_service.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class MealController with ChangeNotifier {
  static const String _storageKey = 'meals';

  final StorageService _storageService;
  final FirestoreService _firestoreService;
  List<Meal> _meals = [];
  String? _userId;

  MealController(this._storageService, this._firestoreService) {
    _loadMeals();
  }

  List<Meal> get meals => _meals;

  void setUserId(String? userId) {
    _userId = userId;
    _loadMeals();
  }

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
    if (_userId != null) {
      // Carregar do Firestore
      _firestoreService.getUserMeals(_userId!).listen((meals) {
        _meals = meals;
        notifyListeners();
      });
    } else if (_storageService.hasKey(_storageKey)) {
      // Carregar do armazenamento local
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

  // Adicionar uma nova refeição
  Future<void> addMeal(Meal meal) async {
    if (_userId != null) {
      await _firestoreService.addMeal(_userId!, meal);
    } else {
      _meals.add(meal);
      await _saveMeals();
      notifyListeners();
    }
  }

  // Atualizar uma refeição existente
  Future<void> updateMeal(Meal updatedMeal) async {
    if (_userId != null) {
      await _firestoreService.updateMeal(_userId!, updatedMeal);
    } else {
      final index = _meals.indexWhere((meal) => meal.id == updatedMeal.id);
      if (index != -1) {
        _meals[index] = updatedMeal;
        await _saveMeals();
        notifyListeners();
      }
    }
  }

  // Excluir uma refeição
  Future<void> deleteMeal(String id) async {
    if (_userId != null) {
      await _firestoreService.deleteMeal(_userId!, id);
    } else {
      _meals.removeWhere((meal) => meal.id == id);
      await _saveMeals();
      notifyListeners();
    }
  }

  // Avaliar uma refeição
  Future<void> rateMeal(String id, int rating) async {
    final index = _meals.indexWhere((meal) => meal.id == id);
    if (index != -1) {
      final updatedMeal = _meals[index].copyWith(rating: rating);
      if (_userId != null) {
        await _firestoreService.updateMeal(_userId!, updatedMeal);
      } else {
        _meals[index] = updatedMeal;
        await _saveMeals();
        notifyListeners();
      }
    }
  }

  // Salvar refeições no armazenamento
  Future<void> _saveMeals() async {
    final List<Map<String, dynamic>> mealsData =
        _meals.map((meal) => meal.toMap()).toList();
    await _storageService.saveList(_storageKey, mealsData);
  }

  // Adicionar dados de exemplo
  void _addSampleData() {
    final now = DateTime.now();
    _meals = [
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Café da Manhã',
        description: 'Ovos mexidos com pão integral',
        calories: 350,
        protein: 20,
        carbs: 30,
        fat: 15,
        rating: 4,
        difficulty: 'Fácil',
        prepTime: 15,
        ingredients: ['Ovos', 'Pão integral', 'Manteiga', 'Sal', 'Pimenta'],
        instructions:
            'Mexa os ovos e tempere com sal e pimenta. Frite na manteiga.',
        time: '08:00',
      ),
      Meal(
        id: const Uuid().v4(),
        date: now,
        name: 'Almoço',
        description: 'Frango grelhado com arroz e salada',
        calories: 550,
        protein: 35,
        carbs: 45,
        fat: 20,
        rating: 5,
        difficulty: 'Médio',
        prepTime: 30,
        ingredients: [
          'Peito de frango',
          'Arroz',
          'Alface',
          'Tomate',
          'Cenoura',
          'Azeite',
          'Sal',
        ],
        instructions: 'Grelhe o frango e prepare o arroz. Monte a salada.',
        time: '12:30',
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

    _saveMeals();
  }
}
