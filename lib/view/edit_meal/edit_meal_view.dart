import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:provider/provider.dart';

class EditMealScreen extends StatefulWidget {
  final Meal meal;

  const EditMealScreen({super.key, required this.meal});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  late String _mealType;
  bool _isLoading = false;

  final List<String> _mealTypes = [
    'Café da Manhã',
    'Almoço',
    'Lanche',
    'Jantar',
    'Ceia',
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar os controllers com os valores da refeição existente
    _nameController = TextEditingController(text: widget.meal.description);
    _ingredientsController = TextEditingController(
      text: widget.meal.ingredients.join('\n'),
    );
    _instructionsController = TextEditingController(
      text: widget.meal.instructions,
    );
    _caloriesController = TextEditingController(
      text: widget.meal.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.meal.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.meal.carbs.toString(),
    );
    _fatController = TextEditingController(text: widget.meal.fat.toString());

    // Inicializar os outros campos
    final timeParts = widget.meal.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    _selectedDate = widget.meal.date;
    _mealType = widget.meal.name;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateMeal() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final mealController = Provider.of<MealController>(
        context,
        listen: false,
      );

      // Converter os ingredientes de texto para lista
      final List<String> ingredients =
          _ingredientsController.text
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();

      // Criar a refeição atualizada
      final updatedMeal = widget.meal.copyWith(
        date: _selectedDate,
        name: _mealType,
        description: _nameController.text,
        time:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        ingredients: ingredients,
        instructions: _instructionsController.text,
      );

      // Atualizar a refeição
      mealController.updateMeal(updatedMeal);

      // Simulando o salvamento da refeição
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refeição atualizada com sucesso!')),
          );

          // Voltar para a tela anterior
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Refeição',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      const Text(
                        'Informações Básicas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nome da refeição
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Refeição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant_menu),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um nome para a refeição';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo de refeição (dropdown)
                      DropdownButtonFormField<String>(
                        value: _mealType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Refeição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            _mealTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _mealType = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Horário
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Horário',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Informações nutricionais
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
                      const Text(
                        'Informações Nutricionais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _caloriesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Calorias',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_fire_department),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Proteínas (g)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.fitness_center),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _carbsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Carboidratos (g)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.grain),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Gorduras (g)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.water_drop),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredientes
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
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ingredientsController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Lista de Ingredientes',
                          hintText: 'Digite cada ingrediente em uma nova linha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.list),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira pelo menos um ingrediente';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instruções
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
                      const Text(
                        'Instruções',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Modo de Preparo',
                          hintText: 'Digite as instruções de preparo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.menu_book),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira as instruções de preparo';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Salvar Alterações',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
