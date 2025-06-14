import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/shopping_list/shopping_list_controller.dart';
import 'package:pdm_fatec_1/model/shopping_item_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  // Lista de categorias
  final List<String> _categories = [
    'Todos',
    'Frutas',
    'Verduras',
    'Laticínios',
    'Carnes',
    'Grãos',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
    final shoppingListController = Provider.of<ShoppingListController>(context);
    final filteredItems = shoppingListController.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(
              shoppingListController.showOnlyPending
                  ? Icons.check_box_outline_blank
                  : Icons.check_box,
              color: Colors.white,
            ),
            onPressed: () {
              shoppingListController.setShowOnlyPending(
                !shoppingListController.showOnlyPending,
              );
            },
            tooltip:
                shoppingListController.showOnlyPending
                    ? 'Mostrar Todos'
                    : 'Mostrar Apenas Pendentes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar itens...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                shoppingListController.setSearchQuery(value);
              },
            ),
          ),
          // Filtro de categorias
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected =
                    category == shoppingListController.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        shoppingListController.setSelectedCategory(category);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // Resumo da lista
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total de Itens',
                      filteredItems.length.toString(),
                      Icons.shopping_basket,
                      Colors.blue,
                    ),
                    _buildSummaryItem(
                      'Pendentes',
                      filteredItems
                          .where((item) => !item.isChecked)
                          .length
                          .toString(),
                      Icons.shopping_cart,
                      Colors.orange,
                    ),
                    _buildSummaryItem(
                      'Comprados',
                      filteredItems
                          .where((item) => item.isChecked)
                          .length
                          .toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de itens
          Expanded(
            child:
                filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];

                        return Dismissible(
                          key: Key(item.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            shoppingListController.deleteItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} removido da lista'),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CheckboxListTile(
                              value: item.isChecked,
                              onChanged: (value) {
                                shoppingListController.toggleItem(item.id);
                              },
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  decoration:
                                      item.isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantidade: ${item.quantity}'),
                                  if (item.notes.isNotEmpty)
                                    Text(
                                      'Obs: ${item.notes}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: _getCategoryColor(
                                  item.category,
                                ),
                                child: Text(
                                  item.category[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              activeColor: Colors.orange,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: Colors.orange,
        heroTag: 'shoppingListFab',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Adiciona um novo item à lista
  void _addItem() {
    showDialog(
      context: context,
      builder:
          (context) => _AddItemDialog(
            categories: _categories.where((c) => c != 'Todos').toList(),
            onAdd: (item) {
              final shoppingListController =
                  Provider.of<ShoppingListController>(context, listen: false);
              shoppingListController.addItem(item);
            },
          ),
    );
  }

  // Widget para mostrar estado vazio
  Widget _buildEmptyState() {
    final shoppingListController = Provider.of<ShoppingListController>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shoppingListController.searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.shopping_cart,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            shoppingListController.searchQuery.isNotEmpty
                ? 'Nenhum item encontrado para "${shoppingListController.searchQuery}"'
                : 'Sua lista de compras está vazia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            shoppingListController.searchQuery.isNotEmpty
                ? 'Tente uma busca diferente'
                : 'Adicione itens usando o botão abaixo',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar um item do resumo
  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Retorna uma cor baseada na categoria
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Frutas':
        return Colors.red;
      case 'Verduras':
        return Colors.green;
      case 'Laticínios':
        return Colors.blue;
      case 'Carnes':
        return Colors.brown;
      case 'Grãos':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }
}

// Dialog para adicionar novos itens
class _AddItemDialog extends StatefulWidget {
  final List<String> categories;
  final Function(ShoppingItem) onAdd;

  const _AddItemDialog({required this.categories, required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Item',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items:
                    widget.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                ShoppingItem(
                  id: const Uuid().v4(),
                  name: _nameController.text,
                  quantity: double.tryParse(_quantityController.text) ?? 1.0,
                  unit: 'un', // Unidade padrão
                  category: _selectedCategory,
                  isChecked: false,
                  notes: _notesController.text,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
