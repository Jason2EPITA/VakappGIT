import 'package:cloud_firestore/cloud_firestore.dart';

class MessObj {
  String text;
  Timestamp timestamp;

  MessObj({required this.text, required this.timestamp});
}