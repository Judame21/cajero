import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cajero/screens/login.dart'; // Importa la pantalla de Login

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController(); // Controlador para el nombre

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String name = _nameController.text.trim(); // Obtener el nombre

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor, completa todos los campos');
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: 'Las contraseñas no coinciden');
      return;
    }

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Actualizar el nombre para mostrar en Firebase Authentication
        await user.updateDisplayName(name);
        await user.reload();

        // Guardar el nombre y otros datos en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': name,
          'email': email,
          'saldo': 0.0, // Saldo inicial
          'creationTime': FieldValue.serverTimestamp(),
        });

        print('Usuario registrado con ID: ${user.uid} y nombre: $name');
        Fluttertoast.showToast(msg: '¡Registro exitoso!');
        Navigator.pushReplacement( // Usamos pushReplacement para ir al Login y no poder volver con el botón atrás
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Error al registrar usuario: ${e.code}');
      String errorMessage = 'Ocurrió un error durante el registro.';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Ya existe una cuenta con este correo electrónico.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo electrónico no es válido.';
      }
      Fluttertoast.showToast(msg: errorMessage);
    } catch (e) {
      print('Error inesperado: $e');
      Fluttertoast.showToast(msg: 'Ocurrió un error inesperado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Volver a la pantalla de login
              },
              child: Text('¿Ya tienes una cuenta? Inicia sesión'),
            ),
          ],
        ),
      ),
    );
  }
}