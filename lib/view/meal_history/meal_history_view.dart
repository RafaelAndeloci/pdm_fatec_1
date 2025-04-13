import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:provider/provider.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  // Filtros
  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = [
    'Todos',
    'Café da Manhã',
    'Almoço',
    'Lanche',
    'Jantar',
    'Ceia',
  ];

  // Exemplo de dados de histórico
  final List<Map<String, dynamic>> _mealHistory = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'name': 'Café da Manhã',
      'description': 'Aveia com frutas e mel',
      'rating': 4,
      'calories': 320,
      'protein': 12,
      'carbs': 45,
      'fat': 8,
      'imageUrl': null,
      'difficulty': 'Fácil',
      'prepTime': 10,
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'name': 'Almoço',
      'description': 'Salada com frango grelhado',
      'rating': 5,
      'calories': 480,
      'protein': 35,
      'carbs': 25,
      'fat': 15,
      'imageUrl': null,
      'difficulty': 'Médio',
      'prepTime': 30,
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'name': 'Café da Manhã',
      'description': 'Sanduíche integral com queijo e tomate',
      'rating': 3,
      'calories': 350,
      'protein': 15,
      'carbs': 40,
      'fat': 12,
      'imageUrl': null,
      'difficulty': 'Fácil',
      'prepTime': 5,
    },
    {
      'id': '4',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'name': 'Almoço',
      'description': 'Macarrão com molho de tomate e manjericão',
      'rating': 4,
      'calories': 520,
      'protein': 18,
      'carbs': 80,
      'fat': 10,
      'imageUrl': null,
      'difficulty': 'Médio',
      'prepTime': 25,
    },
    {
      'id': '5',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'name': 'Jantar',
      'description': 'Sopa de legumes com torradinhas',
      'rating': 4,
      'calories': 280,
      'protein': 8,
      'carbs': 30,
      'fat': 7,
      'imageUrl': null,
      'difficulty': 'Médio',
      'prepTime': 40,
    },
    {
      'id': '6',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'name': 'Café da Manhã',
      'description': 'Vitamina de banana com aveia',
      'rating': 5,
      'calories': 300,
      'protein': 10,
      'carbs': 50,
      'fat': 5,
      'imageUrl': null,
      'difficulty': 'Fácil',
      'prepTime': 5,
    },
    {
      'id': '7',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'name': 'Lanche',
      'description': 'Iogurte com granola e frutas',
      'rating': 5,
      'calories': 200,
      'protein': 8,
      'carbs': 30,
      'fat': 4,
      'imageUrl': null,
      'difficulty': 'Fácil',
      'prepTime': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mealController = Provider.of<MealController>(context);
    List<Meal> filteredMeals =
        _selectedFilter == 'Todos'
            ? mealController.meals
            : mealController.getMealsByType(_selectedFilter);

    final groupedMeals = _getGroupedMeals(filteredMeals);
    final sortedDates =
        groupedMeals.keys.toList()..sort((a, b) {
          final partsA = a.split('/').map(int.parse).toList();
          final partsB = b.split('/').map(int.parse).toList();
          final dateA = DateTime(partsA[2], partsA[1], partsA[0]);
          final dateB = DateTime(partsB[2], partsB[1], partsB[0]);
          return dateB.compareTo(
            dateA,
          ); // Ordenar do mais recente para o mais antigo
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Refeições',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = filter == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Resumo nutricional (últimos 7 dias)
          _buildNutritionalSummary(),

          // Lista de refeições
          Expanded(
            child:
                sortedDates.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final dateString = sortedDates[index];
                        final meals = groupedMeals[dateString]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                _formatDateHeader(dateString),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: meals.length,
                              itemBuilder: (context, mealIndex) {
                                final meal = meals[mealIndex];
                                return _buildMealCard(meal);
                              },
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Filtra as refeições com base na seleção
  List<Meal> _getFilteredMeals(List<Meal> meals) {
    if (_selectedFilter == 'Todos') {
      return meals;
    }
    return meals.where((meal) => meal.name == _selectedFilter).toList();
  }

  // Obtém refeições agrupadas por data
  Map<String, List<Meal>> _getGroupedMeals(List<Meal> filteredMeals) {
    final Map<String, List<Meal>> grouped = {};

    for (var meal in filteredMeals) {
      final date = meal.date;
      final dateString = '${date.day}/${date.month}/${date.year}';

      if (!grouped.containsKey(dateString)) {
        grouped[dateString] = [];
      }
      grouped[dateString]!.add(meal);
    }

    return grouped;
  }

  // Card para cada refeição
  Widget _buildMealCard(Meal meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Implementar navegação para detalhes da refeição
          _showMealDetails(meal);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem ou placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        meal.imageUrl != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                meal.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Icon(
                              Icons.restaurant,
                              color: Colors.grey[600],
                              size: 40,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Avaliação com estrelas
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < meal.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${meal.difficulty} • ${meal.prepTime} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              // Informações nutricionais
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNutrientInfo('Calorias', '${meal.calories} kcal'),
                  _buildNutrientInfo('Proteínas', '${meal.protein}g'),
                  _buildNutrientInfo('Carboidratos', '${meal.carbs}g'),
                  _buildNutrientInfo('Gorduras', '${meal.fat}g'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Informação nutricional
  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Resumo nutricional dos últimos 7 dias
  Widget _buildNutritionalSummary() {
    final mealController = Provider.of<MealController>(context);
    final meals = mealController.meals;

    // Calcular média dos últimos 7 dias
    final now = DateTime.now();
    final last7DaysMeals =
        meals.where((meal) {
          final difference = now.difference(meal.date).inDays;
          return difference < 7;
        }).toList();

    if (last7DaysMeals.isEmpty) {
      return const SizedBox();
    }

    final avgCalories =
        last7DaysMeals.fold(0, (sum, meal) => sum + meal.calories) ~/
        last7DaysMeals.length;
    final avgProtein =
        last7DaysMeals.fold(0, (sum, meal) => sum + meal.protein) ~/
        last7DaysMeals.length;
    final avgCarbs =
        last7DaysMeals.fold(0, (sum, meal) => sum + meal.carbs) ~/
        last7DaysMeals.length;
    final avgFat =
        last7DaysMeals.fold(0, (sum, meal) => sum + meal.fat) ~/
        last7DaysMeals.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consumo Médio (Últimos 7 dias)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Calorias',
                    '$avgCalories kcal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    'Proteínas',
                    '${avgProtein}g',
                    Icons.fitness_center,
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    'Carboidratos',
                    '${avgCarbs}g',
                    Icons.grain,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Gorduras',
                    '${avgFat}g',
                    Icons.opacity,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir um item do resumo
  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Widget para mostrar estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma refeição no histórico',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas refeições aparecerão aqui depois de adicionadas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Formata a string de data para exibição
  String _formatDateHeader(String dateString) {
    final parts = dateString.split('/').map(int.parse).toList();
    final date = DateTime(parts[2], parts[1], parts[0]);
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoje';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Ontem';
    } else {
      return dateString;
    }
  }

  // Exibe detalhes da refeição
  void _showMealDetails(Meal meal) {
    final mealController = Provider.of<MealController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(meal.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Imagem ou placeholder
              Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      meal.imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              meal.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Icon(
                            Icons.restaurant,
                            color: Colors.grey[600],
                            size: 60,
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Descrição
              const Text(
                'Descrição',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(meal.description, style: TextStyle(color: Colors.grey[800])),
              const SizedBox(height: 24),

              // Informações nutricionais
              const Text(
                'Informações Nutricionais',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDetailedNutrient(
                    'Calorias',
                    '${meal.calories} kcal',
                    Colors.orange,
                  ),
                  _buildDetailedNutrient(
                    'Proteínas',
                    '${meal.protein}g',
                    Colors.red,
                  ),
                  _buildDetailedNutrient(
                    'Carboidratos',
                    '${meal.carbs}g',
                    Colors.blue,
                  ),
                  _buildDetailedNutrient(
                    'Gorduras',
                    '${meal.fat}g',
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avaliação com estrelas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Avaliação',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < meal.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          final rating = index + 1;
                          mealController.rateMeal(meal.id, rating);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avaliação atualizada!'),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),

              const Spacer(),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implementar compartilhamento
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidade de compartilhar em desenvolvimento',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Adicionar à lista de refeições planejadas
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Refeição adicionada ao planejamento',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Planejar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para informações detalhadas de nutrientes
  Widget _buildDetailedNutrient(String label, String value, Color color) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Diálogo de confirmação para excluir uma refeição
  void _showDeleteConfirmation(String mealId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir esta refeição?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final mealController = Provider.of<MealController>(
                    context,
                    listen: false,
                  );
                  mealController.deleteMeal(mealId);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refeição excluída com sucesso'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  // Widget para informações adicionais
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
