class User {
  final String id;
  final String name;
  final String email;
  final bool isAuthenticated;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isAuthenticated = false,
  });

  // Converter o objeto para um mapa (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAuthenticated': isAuthenticated,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'name': name, 'id': id};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], email: json['email'], name: json['name']);
  }

  // Criar um objeto a partir de um mapa (para recuperação de dados)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      isAuthenticated: map['isAuthenticated'] ?? false,
    );
  }

  // Criar um usuário não autenticado (convidado)
  static User guest() {
    return User(
      id: 'guest',
      name: 'Convidado',
      email: '',
      isAuthenticated: false,
    );
  }

  // Criar uma cópia do objeto com algumas alterações
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAuthenticated,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
