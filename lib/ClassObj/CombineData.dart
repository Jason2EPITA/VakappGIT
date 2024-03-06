import 'package:cloud_firestore/cloud_firestore.dart';

class CombinedData {
  final QuerySnapshot snapshot1;
  final QuerySnapshot snapshot2;

  CombinedData(this.snapshot1, this.snapshot2);
}
