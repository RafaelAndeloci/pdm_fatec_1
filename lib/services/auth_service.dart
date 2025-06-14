import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para monitorar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  // Registro com email e senha
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: ${e.toString()}');
    }
  }
}
