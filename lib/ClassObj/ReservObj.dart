import 'package:cloud_firestore/cloud_firestore.dart';


class ReservObj {
  String id; // Assurez-vous que cet ID est récupéré lors de la création de l'objet
  DateTime start;
  DateTime end;
  int approved;
  String user;

  ReservObj({required this.id, required this.start, required this.end, required this.approved, required this.user});

  factory ReservObj.fromDocument(DocumentSnapshot doc) {
    return ReservObj(
      id: doc.id,
      start: (doc['start'] as Timestamp).toDate(),
      end: (doc['end'] as Timestamp).toDate(),
      approved: doc['approved'],
      user: doc['user']
    );
  }
}
