import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/auth/auth_controller.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      final success = await authController.resetPassword(_emailController.text);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email de recuperação enviado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authController.error ?? 'Erro ao enviar email de recuperação',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Esqueceu sua senha?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Digite seu email para receber as instruções de recuperação de senha.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite seu email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, digite um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authController.isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    authController.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Enviar Email de Recuperação',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    authController.isLoading
                        ? null
                        : () => Navigator.pop(context),
                child: const Text('Voltar para o Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
