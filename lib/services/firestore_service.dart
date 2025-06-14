import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdm_fatec_1/model/meal_model.dart';
import 'package:pdm_fatec_1/model/shopping_item_model.dart';
import 'package:pdm_fatec_1/model/user_settings_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleções
  static const String _usersCollection = 'users';
  static const String _mealsCollection = 'meals';
  static const String _shoppingListCollection = 'shopping_list';
  static const String _settingsCollection = 'settings';

  // Referências
  CollectionReference get _usersRef => _firestore.collection(_usersCollection);
  CollectionReference get _mealsRef => _firestore.collection(_mealsCollection);
  CollectionReference get _shoppingListRef =>
      _firestore.collection(_shoppingListCollection);
  CollectionReference get _settingsRef =>
      _firestore.collection(_settingsCollection);

  // Verificar se o usuário está autenticado
  String? get currentUserId => _auth.currentUser?.uid;

  // Verificar se o ID do usuário é válido
  bool _isValidUserId(String userId) {
    return userId.isNotEmpty && userId == currentUserId;
  }

  // Métodos para usuários
  Future<void> createUserProfile(User user) async {
    if (!_isValidUserId(user.uid)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    final doc = await _usersRef.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Métodos para refeições
  Future<void> addMeal(String userId, Meal meal) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _mealsRef
        .doc(userId)
        .collection('user_meals')
        .doc(meal.id)
        .set(meal.toMap());
  }

  Future<void> updateMeal(String userId, Meal meal) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _mealsRef
        .doc(userId)
        .collection('user_meals')
        .doc(meal.id)
        .update(meal.toMap());
  }

  Future<void> deleteMeal(String userId, String mealId) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _mealsRef.doc(userId).collection('user_meals').doc(mealId).delete();
  }

  Stream<List<Meal>> getUserMeals(String userId) {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    return _mealsRef
        .doc(userId)
        .collection('user_meals')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Meal.fromMap(doc.data())).toList(),
        );
  }

  // Métodos para lista de compras
  Future<void> addShoppingItem(String userId, ShoppingItem item) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _shoppingListRef
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> updateShoppingItem(String userId, ShoppingItem item) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _shoppingListRef
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteShoppingItem(String userId, String itemId) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _shoppingListRef.doc(userId).collection('items').doc(itemId).delete();
  }

  Stream<List<ShoppingItem>> getUserShoppingList(String userId) {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    return _shoppingListRef
        .doc(userId)
        .collection('items')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ShoppingItem.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Buscar itens da lista de compras com filtros
  Stream<List<ShoppingItem>> searchShoppingItems(
    String userId, {
    String? searchQuery,
    String? category,
    bool? showOnlyPending,
  }) {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }

    // Criar uma referência para a coleção de itens do usuário
    final itemsRef = _shoppingListRef.doc(userId).collection('items');

    // Construir a consulta base
    Query<Map<String, dynamic>> query = itemsRef;

    // Aplicar filtro de status se necessário
    if (showOnlyPending != null) {
      query = query.where('isChecked', isEqualTo: !showOnlyPending);
    }

    // Aplicar filtro de categoria se necessário
    if (category != null && category != 'Todos') {
      query = query.where('category', isEqualTo: category);
    }

    // Se houver uma busca por texto
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Converter a busca para minúsculas para comparação
      final searchLower = searchQuery.toLowerCase();

      // Se a busca for por prefixo (palavra completa ou início de palavra)
      if (searchLower.length >= 3) {
        // Usar busca por prefixo no Firestore
        query = query.orderBy('name_lower').startAt([searchLower]).endAt([
          searchLower + '\uf8ff',
        ]);
      }
    }

    // Executar a consulta e retornar os resultados
    return query.snapshots().map((snapshot) {
      var items =
          snapshot.docs.map((doc) => ShoppingItem.fromMap(doc.data())).toList();

      // Se houver uma busca por texto, aplicar filtros adicionais localmente
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();

        // Filtrar por texto parcial no nome e notas
        items =
            items.where((item) {
              // Se a busca for curta (menos de 3 caracteres), fazer busca parcial
              if (searchLower.length < 3) {
                return item.name.toLowerCase().contains(searchLower) ||
                    item.notes.toLowerCase().contains(searchLower);
              }

              // Se a busca for mais longa, verificar se o nome começa com a busca
              // ou se está contido nas notas
              return item.name.toLowerCase().startsWith(searchLower) ||
                  item.notes.toLowerCase().contains(searchLower);
            }).toList();
      }

      return items;
    });
  }

  // Métodos para configurações do usuário
  Future<void> saveUserSettings(String userId, UserSettings settings) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    await _settingsRef.doc(userId).set(settings.toMap());
  }

  Future<UserSettings?> getUserSettings(String userId) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    final doc = await _settingsRef.doc(userId).get();
    if (doc.exists) {
      return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<UserSettings?> getUserSettingsStream(String userId) {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    return _settingsRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Método para sincronizar dados locais com o Firestore
  Future<void> syncLocalData(
    String userId, {
    List<Meal>? meals,
    List<ShoppingItem>? shoppingItems,
    UserSettings? settings,
  }) async {
    if (!_isValidUserId(userId)) {
      throw Exception('Usuário não autenticado ou ID inválido');
    }
    final batch = _firestore.batch();

    // Sincronizar refeições
    if (meals != null) {
      final mealsRef = _mealsRef.doc(userId).collection('user_meals');
      for (final meal in meals) {
        batch.set(mealsRef.doc(meal.id), meal.toMap());
      }
    }

    // Sincronizar lista de compras
    if (shoppingItems != null) {
      final shoppingRef = _shoppingListRef.doc(userId).collection('items');
      for (final item in shoppingItems) {
        batch.set(shoppingRef.doc(item.id), item.toMap());
      }
    }

    // Sincronizar configurações
    if (settings != null) {
      batch.set(_settingsRef.doc(userId), settings.toMap());
    }

    await batch.commit();
  }

  // Método para adicionar um documento
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Erro ao adicionar documento: $e');
    }
  }

  // Método para atualizar um documento
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar documento: $e');
    }
  }

  // Método para deletar um documento
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar documento: $e');
    }
  }

  // Método para obter um documento específico
  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Erro ao obter documento: $e');
    }
  }

  // Método para obter todos os documentos de uma coleção
  Stream<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Método para fazer consultas com filtros
  Stream<QuerySnapshot> queryCollection(
    String collection, {
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }
}
