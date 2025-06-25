import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Teste Firebase')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              firestore.collection('teste').add({
                'mensagem': 'Teste de integração Firebase',
                'timestamp': FieldValue.serverTimestamp(),
              });
            },
            child: Text('Enviar para o Firestore'),
          ),
        ),
      ),
    );
  }
}