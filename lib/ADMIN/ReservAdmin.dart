// Importez la bibliothèque intl.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/ClassObj/ReservObj.dart';
import 'package:myapp/services/authentification.dart';



class ReservAdmin extends StatefulWidget {
  const ReservAdmin({super.key});
  @override
  State<ReservAdmin> createState() => _ReservAdminState();
}

class _ReservAdminState extends State<ReservAdmin>{
  List<ReservObj> _reservList = [];
  Map<String, List<ReservObj>> _userReservations = {};


  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }


//Charger toutes les reservations des users
//   Future<void> getAllReservations() async {
//     List<ReservObj> reservations = [];
//     Map<String, List<ReservObj>> userReservationsMap = {};
//
//     CollectionReference userReservations = FirebaseFirestore.instance.collection('users');
//
//     try {
//       // Récupérez les documents de la collection Firestore
//       QuerySnapshot querySnapshot = await userReservations.get();
//
//       // Convertissez chaque document en un objet ReservObj et ajoutez-le à la liste
//       for (var doc in querySnapshot.docs) {
//         DateTime start = (doc['start'] as Timestamp).toDate();
//         DateTime end = (doc['end'] as Timestamp).toDate();
//         int approved = doc['approved'];// Assurez-vous que la valeur est un booléen
//         String user = doc['user'];
//         String id = doc.id;
//
//         ReservObj elt = ReservObj(start: start, end: end, approved: approved, user: user, id: id);
//         reservations.add(elt);
//
//         // Ajoutez la réservation à la liste correspondante dans la map
//         if (userReservationsMap[user] == null) {
//           userReservationsMap[user] = [];
//         }
//         userReservationsMap[user]!.add(elt);
//       }
//
//       setState(() {
//         _reservList = reservations;
//         _userReservations = userReservationsMap;
//       });
//     } catch (e) {
//       print('Erreur lors de la récupération des réservations: $e');
//     }
//   }

  Stream<List<ReservObj>> getReservationsStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        DateTime start = (doc['start'] as Timestamp).toDate();
        DateTime end = (doc['end'] as Timestamp).toDate();
        int approved = doc['approved'];
        String user = doc['user'];
        String id = doc.id;
        return ReservObj(start: start, end: end, approved: approved, user: user, id: id);
      }).toList();
    });
  }

// La fonction pour récupérer toutes les réservations

  void _toggleReservationApproval(ReservObj reservation, int newStatus) {
    setState(() {
      reservation.approved = newStatus;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(reservation.id)
        .update({'approved': newStatus})
        .then((_) => print('Reservation status updated'))
        .catchError((error) => print('Failed to update reservation status: $error'));
  }
  void _showApprovalDialog(BuildContext context, ReservObj reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Reservation Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Approved'),
                  onTap: () {
                    _toggleReservationApproval(reservation, 1);
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Refused'),
                  onTap: () {
                    _toggleReservationApproval(reservation, 0);
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Pending'),
                  onTap: () {
                    _toggleReservationApproval(reservation, 2);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: StreamBuilder<List<ReservObj>>(
        stream: getReservationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des données'));
          }
          List<ReservObj> reservations = snapshot.data!;
          Map<String, List<ReservObj>> userReservationsMap = {};
          for (var reservation in reservations) {
            userReservationsMap.putIfAbsent(reservation.user, () => []).add(reservation);
          }

          return ListView.builder(
            itemCount: userReservationsMap.keys.length,
            itemBuilder: (context, index) {
              String user = userReservationsMap.keys.elementAt(index);
              List<ReservObj> userReservations = userReservationsMap[user]!;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Row(children: [const Text("User: ", style: TextStyle(color: Colors.blue),), Text(user)]),
                  subtitle: const Text('Tap to view reservations'),
                  children: userReservations.map((ReservObj reservation) {
                    return Column(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Text('From: ', style: TextStyle(color: Colors.blue),), Text(formatDate(reservation.start))]),
                              Row(children: [const Text('To: ', style: TextStyle(color: Colors.blue),), Text(formatDate(reservation.end))]),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              const Text('Approved: ', style: TextStyle(color: Colors.blue)),
                              Text(reservation.approved == 1 ? "Yes" : reservation.approved == 0 ? "No" : "Pending")
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(reservation.approved == 1 ? Icons.check : reservation.approved == 0 ? Icons.close : Icons.hourglass_top),
                            color: reservation.approved == 1 ? Colors.green : reservation.approved == 0 ? Colors.red : Colors.orange,
                            onPressed: () {
                              _showApprovalDialog(context, reservation);
                            },
                          ),
                        ),
                        const Divider(), // Ajoutez un Divider ici
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
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