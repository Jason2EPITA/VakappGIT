import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/ClassObj/ReservObj.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.googleEmail});
  final String googleEmail;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}
class _ReservationPageState extends State<ReservationPage> {

  List<ReservObj> reservations = [];
  late String googleEmail;

  Future<void> loadDateInfo(String username) async {
    var userReservations = FirebaseFirestore.instance
        .collection('users').where("user", isEqualTo: googleEmail).get();

    try {
      // Récupérez toutes les plages de dates de Firestore
      QuerySnapshot snapshot = await userReservations;

      List<ReservObj> loadedReservations = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        DateTime start = (doc['start'] as Timestamp).toDate();
        DateTime end = (doc['end'] as Timestamp).toDate();
        int approved = doc['approved'];
        String id = doc.id;
        String user = doc['user'];
        ReservObj elt = ReservObj(
            start: start, end: end, approved: approved, user: user ,id: id);
        loadedReservations.add(elt);
      }

      // Mettez à jour l'état avec les nouvelles réservations
      setState(() {
        reservations = loadedReservations;
      });

      // Affichez les plages de dates pour le débogage
      debugList(reservations);
    } catch (e) {
      print(
          'Erreur lors de la récupération des plages de dates de Firestore: $e');
    }
  }


  void debugList(List<ReservObj> list) {
    for (var res in list) {
      print('${res.start} + ${res.end}${res.approved}');
    }
  }

  @override
  void initState() {
    super.initState();
    googleEmail = widget.googleEmail;
    loadDateInfo(googleEmail);
    debugList(reservations);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  void _deleteReservation(BuildContext context, ReservObj reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reservation'),
          content: const Text('Are you sure you want to delete this reservation?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users') // Utilisez la collection appropriée
                    .doc(reservation.id) // Utilisez l'ID du document
                    .delete()
                    .then((_) {
                  setState(() {
                    reservations.remove(reservation);
                  });
                  Navigator.of(context).pop(); // Fermer le dialogue
                })
                    .catchError((error) => print('Failed to delete reservation: $error'));
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          Icon statusIcon;
          String statusText;

          switch (reservation.approved) {
            case 0: // Refusé
              statusIcon = const Icon(Icons.cancel, color: Colors.red);
              statusText = "Refusé";
              break;
            case 1: // Approuvé
              statusIcon = const Icon(Icons.check_circle, color: Colors.green);
              statusText = "Approuvé";
              break;
            case 2: // En cours de vérification
              statusIcon =
              const Icon(Icons.hourglass_full, color: Colors.orange);
              statusText = "En cours de vérification";
              break;
            default:
              statusIcon = const Icon(Icons.help_outline, color: Colors.grey);
              statusText = "Statut inconnu";
          }

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('From: ${formatDate(reservation.start)} \nTo: ${formatDate(reservation.end)}'),
              subtitle: Text('Status: $statusText'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Important pour limiter la taille de la Row à son contenu
                children: [
                  if(reservation.approved == 1) const Icon(Icons.check_circle, color:  Colors.green,),
                  if (reservation.approved != 1) IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteReservation(context, reservation);
                    },
                  ),
                  if (reservation.approved == 2) const Icon(Icons.hourglass_full, color: Colors.orange),
                  // Vous pouvez ajouter d'autres icônes ici si nécessaire
                ],
              ),
            ),
          );
        },
      ),
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
            width: 80,
          ),
          Text('VakApp',
            style: TextStyle(color: Colors.white,
                fontSize: 30),
          ),],
      ),
    );
  }
}