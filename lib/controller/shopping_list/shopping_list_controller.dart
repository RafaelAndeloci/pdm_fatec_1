import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/shopping_item_model.dart';
import 'package:pdm_fatec_1/services/firestore_service.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class ShoppingListController with ChangeNotifier {
  static const String _storageKey = 'shopping_items';

  final StorageService _storageService;
  final FirestoreService _firestoreService;
  List<ShoppingItem> _items = [];
  String? _userId;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  bool _showOnlyPending = true;

  ShoppingListController(this._storageService, this._firestoreService) {
    _loadItems();
  }

  List<ShoppingItem> get items => _items;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showOnlyPending => _showOnlyPending;

  void setUserId(String? userId) {
    _userId = userId;
    _loadItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadItems();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _loadItems();
  }

  void setShowOnlyPending(bool showOnlyPending) {
    _showOnlyPending = showOnlyPending;
    _loadItems();
  }

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
    if (_userId != null) {
      // Carregar do Firestore com filtros
      _firestoreService
          .searchShoppingItems(
            _userId!,
            searchQuery: _searchQuery,
            category: _selectedCategory,
            showOnlyPending: _showOnlyPending,
          )
          .listen((items) {
            _items = items;
            notifyListeners();
          });
    } else if (_storageService.hasKey(_storageKey)) {
      // Carregar do armazenamento local
      final itemsData = _storageService.getList(_storageKey);
      if (itemsData != null) {
        _items = itemsData.map((data) => ShoppingItem.fromMap(data)).toList();
        // Aplicar filtros localmente
        _applyFilters();
        notifyListeners();
      }
    } else {
      _items = [];
      notifyListeners();
    }
  }

  // Aplicar filtros localmente (para armazenamento local)
  void _applyFilters() {
    var filteredItems = _items;

    // Filtrar por categoria
    if (_selectedCategory != 'Todos') {
      filteredItems =
          filteredItems
              .where((item) => item.category == _selectedCategory)
              .toList();
    }

    // Filtrar por status
    if (_showOnlyPending) {
      filteredItems = filteredItems.where((item) => !item.isChecked).toList();
    }

    // Filtrar por texto de busca
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredItems =
          filteredItems.where((item) {
            return item.name.toLowerCase().contains(query) ||
                item.notes.toLowerCase().contains(query);
          }).toList();
    }

    _items = filteredItems;
  }

  // Adicionar um novo item
  Future<void> addItem(ShoppingItem item) async {
    if (_userId != null) {
      await _firestoreService.addShoppingItem(_userId!, item);
    } else {
      _items.add(item);
      await _saveItems();
      notifyListeners();
    }
  }

  // Atualizar um item existente
  Future<void> updateItem(ShoppingItem updatedItem) async {
    if (_userId != null) {
      await _firestoreService.updateShoppingItem(_userId!, updatedItem);
    } else {
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        await _saveItems();
        notifyListeners();
      }
    }
  }

  // Excluir um item
  Future<void> deleteItem(String id) async {
    if (_userId != null) {
      await _firestoreService.deleteShoppingItem(_userId!, id);
    } else {
      _items.removeWhere((item) => item.id == id);
      await _saveItems();
      notifyListeners();
    }
  }

  // Marcar/desmarcar item
  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = _items[index].copyWith(
        isChecked: !_items[index].isChecked,
      );
      if (_userId != null) {
        await _firestoreService.updateShoppingItem(_userId!, updatedItem);
      } else {
        _items[index] = updatedItem;
        await _saveItems();
        notifyListeners();
      }
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
