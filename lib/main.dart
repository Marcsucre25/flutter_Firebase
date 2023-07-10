import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:get/get.dart';
import 'package:login2/scroll/newPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Usuario no encontrado'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Contraseña incorrecta'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('La contraseña es demasiado débil'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('El correo electrónico ya está en uso'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inicio de Sesión'),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 62, 117, 95),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo Electrónico',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                FilledButton.tonal(
                  onPressed: _login,
                  child: const Text('Iniciar Sesión'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 54, 151, 103)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 16.0),
                FilledButton(
                  onPressed: _register,
                  child: Text('Registro'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 54, 151, 103)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
