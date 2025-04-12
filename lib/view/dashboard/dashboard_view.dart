import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final String _username = "Usuário"; // Seria obtido do sistema de autenticação

  // Exemplo de dados de refeições para demonstração
  final List<Map<String, dynamic>> _todayMeals = [
    {
      'time': '07:00',
      'name': 'Café da Manhã',
      'description': 'Aveia com frutas e mel',
      'calories': 320,
      'protein': 12,
      'carbs': 45,
      'fat': 8,
    },
    {
      'time': '12:00',
      'name': 'Almoço',
      'description': 'Salada com frango grelhado',
      'calories': 480,
      'protein': 35,
      'carbs': 25,
      'fat': 15,
    },
    {
      'time': '16:00',
      'name': 'Lanche',
      'description': 'Iogurte com granola',
      'calories': 180,
      'protein': 8,
      'carbs': 20,
      'fat': 5,
    },
    {
      'time': '20:00',
      'name': 'Jantar',
      'description': 'Sopa de legumes',
      'calories': 250,
      'protein': 10,
      'carbs': 30,
      'fat': 6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('MealPlanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Implementar funcionalidade de notificações
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Navegar para a tela de perfil
            },
          ),
        ],
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
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  // Tab Início
  Widget _buildHomeTab() {
    // Calcular os totais nutricionais do dia
    int totalCalories = _todayMeals.fold(
      0,
      (sum, meal) => sum + (meal['calories'] as int),
    );
    int totalProtein = _todayMeals.fold(
      0,
      (sum, meal) => sum + (meal['protein'] as int),
    );
    int totalCarbs = _todayMeals.fold(
      0,
      (sum, meal) => sum + (meal['carbs'] as int),
    );
    int totalFat = _todayMeals.fold(
      0,
      (sum, meal) => sum + (meal['fat'] as int),
    );

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
                            'Olá, $_username!',
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
                        '$totalCalories kcal',
                        Colors.orange,
                      ),
                      _buildNutrientIndicator(
                        'Proteínas',
                        '${totalProtein}g',
                        Colors.red,
                      ),
                      _buildNutrientIndicator(
                        'Carboidratos',
                        '${totalCarbs}g',
                        Colors.blue,
                      ),
                      _buildNutrientIndicator(
                        'Gorduras',
                        '${totalFat}g',
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayMeals.length,
            itemBuilder: (context, index) {
              final meal = _todayMeals[index];
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
                        meal['time'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    meal['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal['description']),
                      const SizedBox(height: 4),
                      Text(
                        '${meal['calories']} kcal | ${meal['protein']}g proteína',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Exibir opções para a refeição
                    },
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

  // Tab Adicionar Refeição (placeholder)
  Widget _buildAddMealTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 80, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Adicionar Nova Refeição',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aqui você pode adicionar suas refeições ao plano',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Implementar adição de refeição
            },
            icon: const Icon(Icons.add),
            label: const Text('Nova Refeição'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Lista de Compras (placeholder)
  Widget _buildShoppingListTab() {
    return const Center(child: Text('Lista de Compras - Em construção'));
  }

  // Tab Histórico (placeholder)
  Widget _buildHistoryTab() {
    return const Center(child: Text('Histórico de Refeições - Em construção'));
  }

  // Tab Configurações (placeholder)
  Widget _buildSettingsTab() {
    return const Center(child: Text('Configurações - Em construção'));
  }

  // Widget auxiliar para indicadores nutricionais
  Widget _buildNutrientIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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

  // Função para obter a data atual formatada
  String _getCurrentDate() {
    final now = DateTime.now();
    final dayNames = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    final monthNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final dayName = dayNames[now.weekday - 1];
    final day = now.day;
    final month = monthNames[now.month - 1];
    final year = now.year;

    return '$dayName, $day de $month de $year';
  }
}
