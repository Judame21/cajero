import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa el paquete de Firebase Auth

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor, completa todos los campos');
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: 'Las contraseñas no coinciden');
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // El usuario se ha registrado exitosamente
      print('Usuario registrado: ${credential.user?.uid}');
      Fluttertoast.showToast(msg: '¡Registro exitoso!');
      Navigator.pop(context); // Volver al login
      // Opcional: Puedes navegar a otra pantalla aquí
    } on FirebaseAuthException catch (e) {
      // Ocurrió un error durante el registro
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

  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-Up presionado')),
    );
    print('Google Sign-Up presionado');
    // Aquí iría la lógica para la autenticación con Google
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
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signUpWithGoogle,
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
                height: 24,
                width: 24,
              ),
              label: Text('Registrarse con Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}