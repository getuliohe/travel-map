import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Por favor, preencha todos os campos.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica se o e-mail já existe
      var existingUser = await _firestore
          .collection('login')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        _showError("Este e-mail já está em uso.");
        setState(() => _isLoading = false);
        return;
      }
      
      // Adiciona um novo documento à coleção 'login'
      await _firestore.collection('login').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(), // !! PÉSSIMA PRÁTICA DE SEGURANÇA !!
      });
      
      // Mostra sucesso e volta para a tela de login
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cadastro realizado com sucesso! Faça o login.'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();

    } catch (e) {
      _showError("Ocorreu um erro: $e");
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
       }
    }
  }

  void _showError(String message) {
     if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
             const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}