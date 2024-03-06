
import 'package:cloud_firestore/cloud_firestore.dart';

class PriceObj{
  DateTime firstdate;
  DateTime lastdate;
  double price;
  PriceObj({required this.firstdate , required this.lastdate , required this.price});

  // Constructeur pour créer un PriceObj à partir d'un document Firestore
  factory PriceObj.fromDocument(DocumentSnapshot doc) {
    return PriceObj(
      price: doc['price'],
      firstdate: (doc['startDate'] as Timestamp).toDate(),
      lastdate: (doc['endDate'] as Timestamp).toDate(), // Assurez-vous que 'price' existe dans votre document
    );
  }
}