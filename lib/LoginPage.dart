// Importez la bibliothèque intl.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/authentification.dart';
import 'package:sign_in_button/sign_in_button.dart';

class ReservObj {
  DateTime start;
  DateTime end;
  int approved;
  String user;
  String id;


  ReservObj({
    required this.start,
    required this.end,
    required this.approved,
    required this.user,
    required this.id,
  });

}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";


  void _createAccountMail() async {
    await AuthService().CreatWithEmail(
      _emailController.text,
      _passwordController.text,
          (String errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );
  }
  void _login() async {
    await AuthService().LogWithEmail(
      _emailController.text,
      _passwordController.text,
          (String errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );
  }
  void _showResetPasswordDialog() {
    TextEditingController resetEmailController = TextEditingController();
    String resetEmailErrorMessage = ""; // Ajout d'une variable pour stocker le message d'erreur

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Utilisez StatefulBuilder pour mettre à jour l'état dans la boîte de dialogue
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Pour s'assurer que la boîte de dialogue ne prend pas trop de place
                children: [
                  TextField(
                    controller: resetEmailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      errorText: resetEmailErrorMessage.isNotEmpty ? resetEmailErrorMessage : null, // Affiche le message d'erreur si non vide
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Send'),
                  onPressed: () async {
                    try {
                      await AuthService().sendPasswordResetEmail(resetEmailController.text);
                      Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'invalid-email') {
                        setState(() => resetEmailErrorMessage = 'The email address is not valid.');
                      } else {
                        setState(() => resetEmailErrorMessage = 'An error occurred. Please try again later.');
                      }
                    }},),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },),
              ],
            );},
        );},);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: const MyAppBar(),
        body: Center(child:
          SizedBox(
          width: 350
          ,child: Column(children: [
            const SizedBox(height: 150,),
            Text("Welcome to VakApp !",style: TextStyle(fontSize: 16,color: Colors.grey[700]),),
            Text(_errorMessage,style: const TextStyle(color: Colors.red),),
            TextField(
              controller: _emailController,
              decoration:  InputDecoration(
                fillColor: Colors.grey.shade100,
                filled: true,
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration:  InputDecoration(
                fillColor: Colors.grey.shade100,
                filled: true,
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            Row(children: [const SizedBox(width: 200,),TextButton(
              onPressed: _showResetPasswordDialog,
              child: const Text("Forgot Password?"),
            ),],),
            Row(children: [const SizedBox(width: 20,),
              ElevatedButton(onPressed: () async {
                _login();
            }, child: const Text("Sign in")),
              const SizedBox(width: 80,),
              ElevatedButton(onPressed: () async {
                _createAccountMail();
            }, child: const Text("Register now")),],),
            const SizedBox(height: 30,),
            Row(children: [
              const Text("or :"),
              const SizedBox(width: 30,),
              SignInButton(
                Buttons.google,
                text: "Sign in with Google",
                onPressed: () async {
                  await AuthService().signInWithGoogle();
                },),
            ],),
            Row(children: [
              const SizedBox(width: 50,),
              SignInButton(
                Buttons.facebook,
                text: "Sign in with Facebook",
                onPressed: () async {
                  await AuthService().signInWithFacebook();
                },)],)

          ],)
            ,)
          ,)
    );
  }
}


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: const Row(
        children: [
          SizedBox(
            width: 120,
          ),
          Text('VakApp',
            style: TextStyle(color: Colors.white,
                fontSize: 30),
          ),],
      ),
    );
  }
}