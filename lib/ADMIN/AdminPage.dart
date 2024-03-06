// Importez la bibliothèque intl.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/ADMIN/AdminPriceSetting.dart';
import 'package:myapp/ADMIN/ReservAdmin.dart';
import 'package:myapp/ADMIN/MessAdminView.dart';
import 'package:myapp/ClassObj/ReservObj.dart';
import 'package:myapp/services/authentification.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>{
  List<ReservObj> _reservList = [];
  Map<String, List<ReservObj>> _userReservations = {};


  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }


//Charger toutes les reservations des users
  Future<void> getAllReservations() async {
    List<ReservObj> reservations = [];
    Map<String, List<ReservObj>> userReservationsMap = {};

    CollectionReference userReservations = FirebaseFirestore.instance.collection('users');

    try {
      // Récupérez les documents de la collection Firestore
      QuerySnapshot querySnapshot = await userReservations.get();

      // Convertissez chaque document en un objet ReservObj et ajoutez-le à la liste
      for (var doc in querySnapshot.docs) {
        DateTime start = (doc['start'] as Timestamp).toDate();
        DateTime end = (doc['end'] as Timestamp).toDate();
        int approved = doc['approved']; // Assurez-vous que la valeur est un booléen
        String user = doc['user'];
        String id = doc.id;

        ReservObj elt = ReservObj(start: start, end: end, approved: approved, user: user, id: id);
        reservations.add(elt);

        // Ajoutez la réservation à la liste correspondante dans la map
        if (userReservationsMap[user] == null) {
          userReservationsMap[user] = [];
        }
        userReservationsMap[user]!.add(elt);
      }

      setState(() {
        _reservList = reservations;
        _userReservations = userReservationsMap;
      });
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
    }
  }

// La fonction pour récupérer toutes les réservations

  void _toggleReservationApproval(ReservObj reservation) {
    // Mettre à jour l'état de l'objet reservation
    setState(() {
      reservation.approved = 1; // Bascule l'état approved
    });

    // Mettre à jour les données sur Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(reservation.id)
        .update({'approved': reservation.approved})
        .then((_) => print('Reservation approval toggled'))
        .catchError((error) => print('Failed to toggle reservation approval: $error'));
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: Center(
          child: Column(children: [
            const Text("Admin Page",
              style: TextStyle(fontSize: 24),),
            const SizedBox(height: 250,),
            ElevatedButton(
              child: const Text("Voir les réservations"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservAdmin()),);
              },
            ),
            ElevatedButton(
              onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessAdminView()));},style : ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(160, 35)),),
              child: const Text("Voir les messages"),),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  AdminPriceSetting()));},style : ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(160, 35)),),
              child: const Text("Ajouter un prix pour un periode"),),
          ],)
      ),
    );
  }
}


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
   const MyAppBar({super.key});

  @override
  Size get preferredSize =>  const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title:  Row(
        children: [
          IconButton(icon:  const Icon(Icons.logout),
            onPressed: () async{
              await AuthService().signOutGoogle();
            },),
          const SizedBox(
            width: 100,
          ),
          const Text('VakApp',
            style: TextStyle(color: Colors.white,
                fontSize: 30),
          ),
        ],),
    );
  }
}