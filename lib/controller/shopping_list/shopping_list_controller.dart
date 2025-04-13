import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/shopping_item_model.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ShoppingListController with ChangeNotifier {
  static const String _storageKey = 'shopping_items';

  final StorageService _storageService;
  List<ShoppingItem> _items = [];

  ShoppingListController(this._storageService) {
    _loadItems();
  }

  List<ShoppingItem> get items => _items;

  // Obter itens filtrados por categoria
  List<ShoppingItem> getItemsByCategory(String category) {
    if (category == 'Todos') {
      return _items;
    }
    return _items.where((item) => item.category == category).toList();
  }

  // Obter itens pendentes (não marcados)
  List<ShoppingItem> getPendingItems() {
    return _items.where((item) => !item.isChecked).toList();
  }

  // Obter itens concluídos (marcados)
  List<ShoppingItem> getCompletedItems() {
    return _items.where((item) => item.isChecked).toList();
  }

  // Carregar itens do armazenamento
  Future<void> _loadItems() async {
    if (_storageService.hasKey(_storageKey)) {
      final itemsData = _storageService.getList(_storageKey);
      if (itemsData != null) {
        _items = itemsData.map((data) => ShoppingItem.fromMap(data)).toList();
        notifyListeners();
      }
    } else {
      // Adicionar dados de exemplo
      _addSampleData();
    }
  }

  // Adicionar dados de exemplo
  Future<void> _addSampleData() async {
    _items = [
      ShoppingItem(
        id: const Uuid().v4(),
        name: 'Maçãs',
        quantity: '1kg',
        category: 'Frutas',
        isChecked: false,
        notes: 'Preferir maçãs gala',
      ),
      ShoppingItem(
        id: const Uuid().v4(),
        name: 'Frango',
        quantity: '500g',
        category: 'Carnes',
        isChecked: false,
        notes: 'Peito de frango sem pele',
      ),
      ShoppingItem(
        id: const Uuid().v4(),
        name: 'Queijo',
        quantity: '200g',
        category: 'Laticínios',
        isChecked: true,
        notes: 'Queijo minas',
      ),
      ShoppingItem(
        id: const Uuid().v4(),
        name: 'Tomates',
        quantity: '5 unidades',
        category: 'Verduras',
        isChecked: false,
      ),
      ShoppingItem(
        id: const Uuid().v4(),
        name: 'Leite',
        quantity: '1L',
        category: 'Laticínios',
        isChecked: false,
        notes: 'Leite semidesnatado',
      ),
    ];

    await _saveItems();
  }

  // Adicionar um novo item
  Future<void> addItem(ShoppingItem item) async {
    _items.add(item);
    await _saveItems();
    notifyListeners();
  }

  // Atualizar um item existente
  Future<void> updateItem(ShoppingItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      await _saveItems();
      notifyListeners();
    }
  }

  // Excluir um item
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
    notifyListeners();
  }

  // Alternar o status de um item (marcado/desmarcado)
  Future<void> toggleItemStatus(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = _items[index].copyWith(
        isChecked: !_items[index].isChecked,
      );
      _items[index] = updatedItem;
      await _saveItems();
      notifyListeners();
    }
  }

  // Marcar todos os itens
  Future<void> checkAllItems() async {
    _items = _items.map((item) => item.copyWith(isChecked: true)).toList();
    await _saveItems();
    notifyListeners();
  }

  // Desmarcar todos os itens
  Future<void> uncheckAllItems() async {
    _items = _items.map((item) => item.copyWith(isChecked: false)).toList();
    await _saveItems();
    notifyListeners();
  }

  // Remover todos os itens marcados
  Future<void> removeCheckedItems() async {
    _items.removeWhere((item) => item.isChecked);
    await _saveItems();
    notifyListeners();
  }

  // Salvar itens no armazenamento
  Future<void> _saveItems() async {
    final List<Map<String, dynamic>> itemsData =
        _items.map((item) => item.toMap()).toList();
    await _storageService.saveList(_storageKey, itemsData);
  }
}
