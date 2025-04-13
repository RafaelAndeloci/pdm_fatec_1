class Meal {
  final String id;
  final DateTime date;
  final String name;
  final String description;
  final int rating;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String? imageUrl;
  final String difficulty;
  final int prepTime;
  final List<String> ingredients;
  final String instructions;
  final String time;

  Meal({
    required this.id,
    required this.date,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.rating = 0,
    this.imageUrl,
    this.difficulty = 'Médio',
    this.prepTime = 0,
    required this.ingredients,
    required this.instructions,
    required this.time,
  });

  // Converter o objeto para um mapa (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'name': name,
      'description': description,
      'rating': rating,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'ingredients': ingredients,
      'instructions': instructions,
      'time': time,
    };
  }

  // Criar um objeto a partir de um mapa (para recuperação de dados)
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      name: map['name'],
      description: map['description'],
      rating: map['rating'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      imageUrl: map['imageUrl'],
      difficulty: map['difficulty'],
      prepTime: map['prepTime'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      time: map['time'],
    );
  }

  // Criar uma cópia do objeto com algumas alterações
  Meal copyWith({
    String? id,
    DateTime? date,
    String? name,
    String? description,
    int? rating,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    String? imageUrl,
    String? difficulty,
    int? prepTime,
    List<String>? ingredients,
    String? instructions,
    String? time,
  }) {
    return Meal(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      time: time ?? this.time,
    );
  }
}
