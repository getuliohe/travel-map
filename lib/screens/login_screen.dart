import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Procura na coleção 'login' por um documento onde o campo 'email' é igual ao digitado
      var querySnapshot = await _firestore
          .collection('login')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Se a lista de documentos for vazia, o email não foi encontrado
        _showError("Usuário não encontrado.");
        return;
      }
      
      // Se encontrou, pega os dados do primeiro documento
      var userData = querySnapshot.docs.first.data();
      
      // !! ALERTA DE SEGURANÇA !! Compara a senha em texto puro
      if (userData['password'] == _passwordController.text.trim()) {
        // Se a senha estiver correta, navega para a tela inicial
        Navigator.of(context).pushReplacementNamed('/home', arguments: userData);
      } else {
        _showError("Senha incorreta.");
      }

    } catch (e) {
      _showError("Ocorreu um erro: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    onPressed: _login,
                    child: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              child: const Text('Não tem uma conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}