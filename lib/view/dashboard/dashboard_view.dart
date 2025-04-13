import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/controller/settings/user_settings_controller.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:pdm_fatec_1/view/add_meal/add_meal_view.dart';
import 'package:pdm_fatec_1/view/meal_history/meal_history_view.dart';
import 'package:pdm_fatec_1/view/settings/settings_view.dart';
import 'package:pdm_fatec_1/view/shop_list/shop_list_view.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('MealPlanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildAddMealTab(),
          _buildShoppingListTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  // Navegar para adicionar refeição
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                backgroundColor: Colors.orange,
                heroTag: 'dashboardFab',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  // Tab Início
  Widget _buildHomeTab() {
    final mealController = Provider.of<MealController>(context);
    final userSettingsController = Provider.of<UserSettingsController>(context);

    final now = DateTime.now();
    final List<Meal> todayMeals = mealController.getMealsForDay(now);
    final nutritionStats = mealController.getNutritionStatsForDay(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Boas-vindas e data
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, ${userSettingsController.userName}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'No caminho certo!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resumo Nutricional de Hoje',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutrientIndicator(
                        'Calorias',
                        '${nutritionStats['calories']} kcal',
                        Colors.orange,
                      ),
                      _buildNutrientIndicator(
                        'Proteínas',
                        '${nutritionStats['protein']}g',
                        Colors.red,
                      ),
                      _buildNutrientIndicator(
                        'Carboidratos',
                        '${nutritionStats['carbs']}g',
                        Colors.blue,
                      ),
                      _buildNutrientIndicator(
                        'Gorduras',
                        '${nutritionStats['fat']}g',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Título da seção
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Refeições de Hoje',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navegação para visualização semanal
                },
                child: const Text(
                  'Ver Semana',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Lista de refeições
          todayMeals.isEmpty
              ? _buildEmptyMealsList()
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayMeals.length,
                itemBuilder: (context, index) {
                  final meal = todayMeals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            meal.time,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        meal.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal.description),
                          const SizedBox(height: 4),
                          Text(
                            '${meal.calories} kcal | ${meal.protein}g proteína',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(meal.id);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Excluir'),
                              ),
                            ],
                      ),
                      onTap: () {
                        // Abrir detalhes da refeição
                      },
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  // Widget para exibir quando não há refeições
  Widget _buildEmptyMealsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma refeição planejada para hoje',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione refeições usando o botão +',
            style: TextStyle(color: Colors.grey[500]),
          ),
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

  // Tab Adicionar Refeição
  Widget _buildAddMealTab() {
    return const AddMealScreen();
  }

  // Tab Lista de Compras
  Widget _buildShoppingListTab() {
    return const ShoppingListScreen();
  }

  // Tab Histórico
  Widget _buildHistoryTab() {
    return const MealHistoryScreen();
  }

  // Tab Configurações
  Widget _buildSettingsTab() {
    return const SettingsScreen();
  }

  // Widget auxiliar para indicadores nutricionais
  Widget _buildNutrientIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
