// Importez la bibliothèque intl.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/authentification.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'VerificationEmailScreen.dart';

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
  //Version 2 pour la verif de l'email
  void _createAccountMail2() async {
    await AuthService().createWithEmail2(
      _emailController.text,
      _passwordController.text,
          (String errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
        // Affiche un Snackbar avec le message d'erreur si l'email est déjà utilisé
        if(errorMessage == "Un compte existe déjà avec cet e-mail.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Si l'erreur n'est pas due à un email déjà utilisé, redirige vers VerificationEmailScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerificationEmailScreen()),
          );
        }
      },
      context,
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
            Text("Bienvenue chez VakApp !",style: TextStyle(fontSize: 16,color: Colors.grey[700]),),
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
            Row(children: [const SizedBox(width: 180,),TextButton(
              onPressed: _showResetPasswordDialog,
              child: const Text("Mot de passe oublié ?"),
            ),],),
            Row(children: [const SizedBox(width: 10,),
              ElevatedButton(onPressed: () async {
                _login();
            }, child: const Text("Se connecter")),
              const SizedBox(width: 40,),
              ElevatedButton(onPressed: () async {
                _createAccountMail2();
            }, child: const Text("Créer un compte")),],),
            const SizedBox(height: 30,),
            Row(children: [
              const Text("ou :"),
              const SizedBox(width: 30,),
              SignInButton(
                Buttons.google,
                text: "Connection avec Google",
                onPressed: () async {
                  await AuthService().signInWithGoogle();
                },),
            ],),
            //Decommenter pour activer la connexion avec facebook (mais il faut regler le probleme)
            // Row(children: [
            //   const SizedBox(width: 50,),
            //   SignInButton(
            //     Buttons.facebook,
            //     text: "Connection via Facebook",
            //     onPressed: () async {
            //       await AuthService().signInWithFacebook();
            //     },)],)
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