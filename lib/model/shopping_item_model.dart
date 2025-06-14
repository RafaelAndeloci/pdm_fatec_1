class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final bool isChecked;
  final String notes;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isChecked = false,
    this.notes = '',
  });

  // Converter o objeto para um mapa (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isChecked': isChecked,
      'notes': notes,
    };
  }

  // Criar um objeto a partir de um mapa (para recuperação de dados)
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'],
      category: map['category'],
      isChecked: map['isChecked'] ?? false,
      notes: map['notes'] ?? '',
    );
  }

  // Criar uma cópia do objeto com algumas alterações
  ShoppingItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? isChecked,
    String? notes,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
    );
  }
}
