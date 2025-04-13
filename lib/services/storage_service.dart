import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  // Inicializar o serviço de armazenamento
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Salvar dados em formato JSON
  Future<bool> saveData(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  // Salvar lista de dados em formato JSON
  Future<bool> saveList(String key, List<Map<String, dynamic>> list) async {
    return await _prefs.setString(key, jsonEncode(list));
  }

  // Recuperar dados em formato JSON
  Map<String, dynamic>? getData(String key) {
    String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Recuperar lista de dados em formato JSON
  List<Map<String, dynamic>>? getList(String key) {
    String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }

    List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
    return decodedList.map((item) => item as Map<String, dynamic>).toList();
  }

  // Remover dados
  Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }

  // Verificar se a chave existe
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  // Limpar todos os dados
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
