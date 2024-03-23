import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../VerificationEmailScreen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  final String _errorMessage = "";


//Connexion avec Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Déclencher le flux d'authentification
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Si l'utilisateur annule la connexion
      if (loginResult.status == LoginStatus.cancelled) {
        return null;
      }

      // Créer un nouvel identifiant
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Une fois connecté, renvoyez l'identifiant de l'utilisateur
      return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      print('Erreur lors de la connexion avec Facebook: $e');
      return null;
    }
  }

// Connexion avec Anonyme
  Future<void> authAnonym() =>
      _auth.signInAnonymously().then((credetial) => null);

Stream<User?> get userChanged => _auth.authStateChanges();

Future<void> logOut() => _auth.signOut().then((value) => null);

// Méthode pour envoyer un lien de réinitialisation de mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

//Connexion avec Email et mot de passe
  Future<void> CreatWithEmail(
      String email,
      String password,
      Function(String) onError,
      ) async {
    try {
      // Création de l'utilisateur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Utilisateur créé avec succès
      // ...
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else {
        errorMessage = 'An unexpected error occurred.';
      }
      onError(errorMessage);
    } catch (e) {
      onError('An unexpected error occurred : $e');
    }
  }
  Future<void> LogWithEmail(
      String email,
      String password,
      Function(String) onError,
      ) async {
    try {
      // Connexion de l'utilisateur
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Utilisateur connecté avec succès
      // ...
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      print('Error code: ${e.code}');
      print('Error message: ${e.message}');
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = "The email or password is uncorrect";
      } else {
        errorMessage = "An unexpected error occured";
      }
      onError(errorMessage);
    } catch (e) {
      onError('An unexpected error occurred');
    }
  }
  // Connexion avec le Google
  Future<UserCredential> signInWithGoogle() async {

    if (kIsWeb) return await _auth.signInWithPopup(googleProvider);
    // Déclencher le flux d'authentification
    final googleUser = await _googleSignIn.signIn();

    // obtenir les détails d'autorisation de la demande
    final googleAuth = await googleUser!.authentication;

    // créer un nouvel identifiant
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // une fois connecté, renvoyez l'indentifiant de l'utilisateur
    return await _auth.signInWithCredential(credential);
  }

  // l'état de l'utilisateur en temps réel
  Stream<User?> get user => _auth.authStateChanges();

  // déconnexion
  Future<void> signOutGoogle() async {
    _googleSignIn.signOut();
    return _auth.signOut();
  }
  //conexion avec email version2
  Future<void> createWithEmail2(String email, String password, Function(String) errorCallback, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorCallback("Le mot de passe est trop faible.");
      } else if (e.code == 'email-already-in-use') {
        errorCallback("Un compte existe déjà avec cet e-mail.");
      } else {
        errorCallback("Une erreur est survenue lors de la création du compte.");
      }
    } catch (e) {
      errorCallback("Une erreur est survenue lors de la création du compte. ");
    }
  }
}
