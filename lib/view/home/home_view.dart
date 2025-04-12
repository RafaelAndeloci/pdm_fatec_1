import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to validade e-mail. Yes we use regex on this :P
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    // Verifica se o e-mail tem o formato correto
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  // Function to "validate" Password.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('MealPlanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 200, 20.0, 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Text(
                'Bem-vindo ao MealPlanner!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 40),

              // Campo de E-mail
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Digite seu e-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail, // Validação do e-mail
              ),
              SizedBox(height: 20),

              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: _validatePassword, // Validação da senha
              ),
              SizedBox(height: 20),

              // Botão de Login
              ElevatedButton(
                onPressed: () {
                  // Verifica se o formulário é válido
                  if (_formKey.currentState?.validate() ?? false) {
                    // Se o formulário for válido, podemos proceder com o login
                    print(
                      'E-mail: ${_emailController.text}, Senha: ${_passwordController.text}',
                    );
                    // Aqui você pode adicionar sua lógica de login
                  } else {
                    // Caso o formulário não seja válido, mostramos um feedback
                    print('Formulário inválido');
                  }
                },
                child: Text('Entrar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor do botão
                  // I dont know how to put width: 100% in a button, this framework sucks CSS is superior.
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 154),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Links de "Esqueci minha senha" e "Criar conta"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // Ação para recuperar senha
                      print('Redirecionar para recuperar senha');
                    },
                    child: Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 60),
                  TextButton(
                    onPressed: () {
                      // Ação para registrar novo usuário
                      print('Redirecionar para página de registro');
                    },
                    child: Text(
                      'Criar uma conta',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
