import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cajero/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importa el paquete de Google Sign-In

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor, completa todos los campos');
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // El usuario ha iniciado sesión exitosamente
      print('Usuario logueado: ${credential.user?.uid}');
      Fluttertoast.showToast(msg: '¡Inicio de sesión exitoso!');
      // Navega a la pantalla principal de tu aplicación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Reemplaza HomeScreen() con tu pantalla principal
      );
    } on FirebaseAuthException catch (e) {
      // Ocurrió un error durante el inicio de sesión
      print('Error al iniciar sesión: ${e.code}');
      String errorMessage = 'Ocurrió un error al iniciar sesión.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Correo electrónico o contraseña incorrectos.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Correo electrónico o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo electrónico no es válido.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Esta cuenta de usuario ha sido deshabilitada.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Correo electrónico o contraseña incorrectos.';
      }
      Fluttertoast.showToast(msg: errorMessage);
    } catch (e) {
      print('Error inesperado al iniciar sesión: $e');
      Fluttertoast.showToast(msg: 'Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión con Google
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        print('Usuario de Google logueado: ${user.uid}');
        Fluttertoast.showToast(msg: '¡Inicio de sesión con Google exitoso!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Reemplaza HomeScreen()
        );
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      Fluttertoast.showToast(msg: 'Error al iniciar sesión con Google.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar sesión'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('¿No tienes cuenta? Regístrate aquí'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
                height: 24,
                width: 24,
              ),
              label: Text('Iniciar sesión con Google'),
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

// Recuerda crear tu HomeScreen widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pantalla Principal')),
      body: Center(
        child: Text('¡Bienvenido a la aplicación!'),
      ),
    );
  }
}