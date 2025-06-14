import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/auth/auth_controller.dart';
import 'package:pdm_fatec_1/view/about/about_view.dart';
import 'package:pdm_fatec_1/view/dashboard/dashboard_view.dart';
import 'package:pdm_fatec_1/view/forgot-password/forgot-password_view.dart';
import 'package:pdm_fatec_1/view/register/register_view.dart';
import 'package:provider/provider.dart';
// Importe a tela de dashboard

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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

  // Função para realizar o login
  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await context.read<AuthController>().login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Falha no login. Verifique suas credenciais.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Falha no login. Verifique suas credenciais.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('MealPlanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            tooltip: 'Sobre',
          ),
        ],
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

              // Mensagem de erro (se houver)
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Botão de Login
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor do botão
                  // I dont know how to put width: 100% in a button, this framework sucks CSS is superior.
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 154),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),

              // Links de "Esqueci minha senha" e "Criar conta"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navegar para a tela de Esqueci Minha Senha
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 60),
                  TextButton(
                    onPressed: () {
                      // Navegar para a tela de Cadastro
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Criar uma conta',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),

              // Botão Sobre
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                label: const Text(
                  'Sobre o aplicativo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
