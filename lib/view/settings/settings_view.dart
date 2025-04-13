import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/settings/user_settings_controller.dart';
import 'package:pdm_fatec_1/model/user_settings_model.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Preferências alimentares
  Map<String, bool> _dietaryPreferences = {
    'Vegetariano': false,
    'Vegano': false,
    'Sem Glúten': false,
    'Sem Lactose': false,
    'Baixo Carboidrato': false,
    'Sem Açúcar': false,
  };

  // Notificações
  bool _notifyMealReminders = true;
  bool _notifyShoppingList = true;
  bool _notifyWeeklyReport = true;

  // Dados do usuário
  final TextEditingController _nameController = TextEditingController(
    text: 'Usuário',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'usuario@exemplo.com',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '170',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '70',
  );

  // Metas nutricionais
  final TextEditingController _caloriesGoalController = TextEditingController(
    text: '2000',
  );
  final TextEditingController _proteinGoalController = TextEditingController(
    text: '100',
  );
  final TextEditingController _carbsGoalController = TextEditingController(
    text: '250',
  );
  final TextEditingController _fatGoalController = TextEditingController(
    text: '65',
  );

  // Tema do aplicativo
  String _selectedTheme = 'Claro';
  final List<String> _themeOptions = ['Claro', 'Escuro', 'Sistema'];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  // Carregar as configurações do usuário
  void _loadUserSettings() {
    final userSettingsController = Provider.of<UserSettingsController>(
      context,
      listen: false,
    );
    final settings = userSettingsController.settings;

    setState(() {
      _nameController.text = settings.name;
      _emailController.text = settings.email;
      _heightController.text = settings.height.toString();
      _weightController.text = settings.weight.toString();
      _caloriesGoalController.text = settings.caloriesGoal.toString();
      _proteinGoalController.text = settings.proteinGoal.toString();
      _carbsGoalController.text = settings.carbsGoal.toString();
      _fatGoalController.text = settings.fatGoal.toString();
      _dietaryPreferences = Map<String, bool>.from(settings.dietaryPreferences);
      _notifyMealReminders = settings.notifyMealReminders;
      _notifyShoppingList = settings.notifyShoppingList;
      _notifyWeeklyReport = settings.notifyWeeklyReport;
      _selectedTheme = settings.theme;
    });
  }

  void _saveSettings() {
    final userSettingsController = Provider.of<UserSettingsController>(
      context,
      listen: false,
    );

    // Validar e converter valores numéricos
    final int height = int.tryParse(_heightController.text) ?? 170;
    final int weight = int.tryParse(_weightController.text) ?? 70;
    final int caloriesGoal = int.tryParse(_caloriesGoalController.text) ?? 2000;
    final int proteinGoal = int.tryParse(_proteinGoalController.text) ?? 100;
    final int carbsGoal = int.tryParse(_carbsGoalController.text) ?? 250;
    final int fatGoal = int.tryParse(_fatGoalController.text) ?? 65;

    // Criar objeto de configurações
    final updatedSettings = UserSettings(
      name: _nameController.text,
      email: _emailController.text,
      height: height,
      weight: weight,
      dietaryPreferences: _dietaryPreferences,
      caloriesGoal: caloriesGoal,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
      notifyMealReminders: _notifyMealReminders,
      notifyShoppingList: _notifyShoppingList,
      notifyWeeklyReport: _notifyWeeklyReport,
      theme: _selectedTheme,
    );

    // Atualizar as configurações
    userSettingsController.updateAllSettings(updatedSettings);

    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas com sucesso!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesGoalController.dispose();
    _proteinGoalController.dispose();
    _carbsGoalController.dispose();
    _fatGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil do usuário
            _buildProfileSection(),
            const SizedBox(height: 24),

            // Preferências alimentares
            _buildDietaryPreferencesSection(),
            const SizedBox(height: 24),

            // Metas nutricionais
            _buildNutritionalGoalsSection(),
            const SizedBox(height: 24),

            // Notificações
            _buildNotificationsSection(),
            const SizedBox(height: 24),

            // Configurações do aplicativo
            _buildAppSettingsSection(),
            const SizedBox(height: 24),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Salvar Configurações',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Lógica para fazer logout
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Seção de Perfil
  Widget _buildProfileSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Foto e Nome
            Row(
              children: [
                // Foto de perfil
                InkWell(
                  onTap: () {
                    // Lógica para alterar a foto de perfil
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email (apenas exibição)
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dados físicos
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Preferências Alimentares
  Widget _buildDietaryPreferencesSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferências Alimentares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione suas restrições ou preferências alimentares:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _dietaryPreferences.keys.map((String preference) {
                    return FilterChip(
                      label: Text(preference),
                      selected: _dietaryPreferences[preference]!,
                      onSelected: (bool selected) {
                        setState(() {
                          _dietaryPreferences[preference] = selected;
                        });
                      },
                      selectedColor: Colors.orange.withOpacity(0.3),
                      checkmarkColor: Colors.orange,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Metas Nutricionais
  Widget _buildNutritionalGoalsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metas Nutricionais Diárias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Defina suas metas diárias de nutrientes:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Calorias
            TextFormField(
              controller: _caloriesGoalController,
              decoration: const InputDecoration(
                labelText: 'Calorias (kcal)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Macronutrientes
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Proteínas (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Carboidratos (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Gorduras (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Notificações
  Widget _buildNotificationsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Lembretes de Refeições'),
              subtitle: const Text(
                'Receba notificações para preparar suas refeições',
              ),
              value: _notifyMealReminders,
              onChanged: (bool value) {
                setState(() {
                  _notifyMealReminders = value;
                });
              },
              activeColor: Colors.orange,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Lista de Compras'),
              subtitle: const Text(
                'Receba lembretes sobre sua lista de compras',
              ),
              value: _notifyShoppingList,
              onChanged: (bool value) {
                setState(() {
                  _notifyShoppingList = value;
                });
              },
              activeColor: Colors.orange,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Relatório Semanal'),
              subtitle: const Text(
                'Receba um resumo semanal de suas refeições e nutrição',
              ),
              value: _notifyWeeklyReport,
              onChanged: (bool value) {
                setState(() {
                  _notifyWeeklyReport = value;
                });
              },
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Configurações do App
  Widget _buildAppSettingsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações do Aplicativo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Seleção de tema
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tema do Aplicativo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.color_lens),
              ),
              value: _selectedTheme,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTheme = newValue;
                  });
                }
              },
              items:
                  _themeOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            // Botões de ação
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implementar exportação de dados
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados exportados com sucesso!'),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Exportar Dados'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // Implementar limpeza de cache
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache limpo com sucesso!')),
                );
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Limpar Cache'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
