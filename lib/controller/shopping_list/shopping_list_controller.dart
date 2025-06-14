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

  ShoppingListController(this._storageService, this._firestoreService) {
    _loadItems();
  }

  List<ShoppingItem> get items => _items;

  void setUserId(String? userId) {
    _userId = userId;
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
      // Carregar do Firestore
      _firestoreService.getUserShoppingList(_userId!).listen((items) {
        _items = items;
        notifyListeners();
      });
    } else if (_storageService.hasKey(_storageKey)) {
      // Carregar do armazenamento local
      final itemsData = _storageService.getList(_storageKey);
      if (itemsData != null) {
        _items = itemsData.map((data) => ShoppingItem.fromMap(data)).toList();
        notifyListeners();
      }
    } else {
      _items = [];
      notifyListeners();
    }
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
