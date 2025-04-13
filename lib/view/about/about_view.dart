import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sobre o MealPlanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 70,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'MealPlanner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
            Center(
              child: Text(
                'Versão 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              'Objetivo do Aplicativo',
              'Ajudar o usuário a planejar suas refeições diárias ou semanais de forma prática e organizada. O aplicativo permite definir refeições para cada dia, fazer listas de compras baseadas nas receitas e acompanhar o consumo de nutrientes, promovendo uma alimentação mais equilibrada e um uso mais eficiente dos recursos disponíveis na cozinha.',
            ),

            _buildSection(
              'Sobre o Aplicativo',
              'O MealPlanner é um aplicativo desenvolvido como trabalho para a disciplina de Programação para Dispositivos Móveis. Ele oferece uma solução completa para planejamento alimentar, incluindo gerenciamento de receitas, lista de compras automática e acompanhamento nutricional.',
            ),

            _buildSection(
              'Tecnologias Utilizadas',
              '• Framework: Flutter/Dart\n• Gerenciamento de Estado: Provider/Bloc\n• Banco de Dados: Firebase Firestore\n• Autenticação: Firebase Authentication\n• Armazenamento Local: SharedPreferences/Hive',
            ),

            _buildSection(
              'Funcionalidades',
              '• Planejamento de refeições diárias e semanais\n• Catálogo de receitas\n• Geração automática de lista de compras\n• Histórico de refeições\n• Perfil com preferências alimentares',
            ),

            _buildSection(
              'Equipe de Desenvolvimento',
              'Desenvolvido por:\nRafael Andeloci Rodrigues Gonçalves\n\nTurma de Análise e Desenvolvimento de Sistemas - FATEC\nDisciplina: Programação para Dispositivos Móveis\n© 2023',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
      ],
    );
  }
}
