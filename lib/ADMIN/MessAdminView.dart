import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/ADMIN/ViewMessageAdmin.dart';
import 'package:myapp/ClassObj/MessObj.dart';


class MessAdminView extends StatefulWidget {
  const MessAdminView({super.key});

  @override
  _MessAdminViewState createState() => _MessAdminViewState();
}


class _MessAdminViewState extends State<MessAdminView> {
  Map<String, List<MessObj>> _userMess = {};

  Future<void> loadUser() async {
    List<MessObj> messlist = [];
    Map<String, List<MessObj>> userMessMap = {};

    CollectionReference userMess = FirebaseFirestore.instance.collection('messages');
    try {
      // Récupérez les documents de la collection Firestore
      QuerySnapshot querySnapshot = await userMess.get();

      // Convertissez chaque document en un objet ReservObj et ajoutez-le à la liste
      for (var doc in querySnapshot.docs) {
        String text = (doc['text']);
        Timestamp timestamp = (doc['timestamp']);
        String user = doc['user'];
        String id = doc.id;

        MessObj elt = MessObj(text: text,timestamp: timestamp);
        messlist.add(elt);

        // Ajoutez la réservation à la liste correspondante dans la map
        if (userMessMap[user] == null) {
          userMessMap[user] = [];
        }
        userMessMap[user]!.add(elt);
      }

      setState(() {
        _userMess = userMessMap;
      });
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
    }
  }

@override
void initState() {
    super.initState();
    loadUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Utilisateurs'),
      ),
      body: ListView.builder(
        itemCount: _userMess.keys.length, // Nombre d'utilisateurs uniques
        itemBuilder: (context, index) {
          String user = _userMess.keys.elementAt(index); // Clé actuelle (nom d'utilisateur)

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(user, style: const TextStyle(color: Colors.blue)),
              subtitle: const Text('Appuyez pour voir la conversation'),
              onTap: () {
                // Naviguer vers ViewMessageAdmin avec les messages de l'utilisateur
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewMessageAdmin(username: user, messages: _userMess[user]!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}