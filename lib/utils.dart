import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//
// void checkAndDisplayDialog(bool isChecked) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     final userid = user.uid;
//     final collectionRef = FirebaseFirestore.instance.collection('conditions and cookies');
//
//     final doc = await collectionRef.doc(userid).get();
//     if (!doc.exists) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Dialog(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//                 child: Container(
//                   padding: EdgeInsets.all(15.0),
//                   constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Text(
//                         "Conditions Générales d'Utilisation de l'Application Vakapp",
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20.0),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           padding: EdgeInsets.all(8.0),
//                           child: Scrollbar(
//                             thumbVisibility: true,
//                             child: SingleChildScrollView(
//                               child: RichText(
//                                 text: TextSpan(
//                                   style: TextStyle(color: Colors.black, fontSize: 16.0),
//                                   children: <TextSpan>[
//                                     TextSpan(text: "1. Acceptation des Conditions\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "En téléchargeant ou en utilisant l'application Vakapp, vous acceptez d'être lié par les présentes Conditions Générales d'Utilisation (CGU). Si vous n'acceptez pas ces conditions, vous ne pouvez pas utiliser l'application.\n\n"),
//                                     TextSpan(text: "2. Description du Service\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Vakapp permet aux utilisateurs de réserver des hébergements meublés pour des durées allant jusqu'à 90 jours. Les hébergements sont situés au 45 bd de la Croisette à Cannes 06400 et au 5 rue Victor Cousin 06400 Cannes. Les tarifs varient selon la durée et les dates de réservation.\n\n"),
//                                     TextSpan(text: "3. Réservation et Paiement\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Les réservations se font via l'application avec paiement par carte bancaire. Des réductions via codes promos peuvent être appliquées. Toute réservation est sujette à une confirmation par Vakapp.\n\n"),
//                                     TextSpan(text: "4. Annulation et Remboursement\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Les annulations sont possibles jusqu'à 7 jours avant la date de réservation. Une charge de compensation de 30% du montant payé ne sera pas remboursable.\n\n"),
//                                     TextSpan(text: "5. Utilisation de l'Hébergement\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "L'hébergement est limité à 3 occupants et est classé en Meublé 2 étoiles. Il est équipé de tous les conforts nécessaires pour un séjour agréable.\n\n"),
//                                     TextSpan(text: "6. Responsabilité des Locataires\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Les locataires sont responsables de tous les dommages causés pendant leur séjour. Ils doivent maintenir l'hébergement dans un état correct.\n\n"),
//                                     TextSpan(text: "7. Modification des Conditions\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Vakapp se réserve le droit de modifier les présentes CGU à tout moment. Les utilisateurs seront informés des modifications et devront accepter les nouvelles conditions pour continuer à utiliser l'application.\n\n"),
//                                     TextSpan(text: "8. Confidentialité et Données Personnelles\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "La protection de vos données est importante pour Vakapp. Notre Charte de protection des données à caractère personnel décrit comment nous collectons et utilisons vos données.\n\n"),
//                                     TextSpan(text: "9. Contact et Réclamations\n", style: TextStyle(fontWeight: FontWeight.bold)),
//                                     TextSpan(text: "Pour toute question ou réclamation, vous pouvez contacter Vakapp au +33650793898 ou par email à vakapp.loc@gmail.com.\n\n"),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       CheckboxListTile(
//                         subtitle: Text(
//                           "Je consens à recevoir des offres commerciales et promotionnelles de VAKAPP par SMS, e-mail ou notifications push.",
//                           style: TextStyle(fontSize: 12),
//                         ),
//                         value: isChecked,
//                         onChanged: (bool? newValue) {
//                           setState(() {
//                             isChecked = newValue!;
//                           });
//                         },
//                         controlAffinity: ListTileControlAffinity.leading,
//                         checkColor: Colors.blue,
//                         activeColor: Colors.white,
//                       ),
//                       SizedBox(height: 20.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           Expanded(
//                             child: TextButton(
//                               child: Text("Refuser"),
//                               onPressed: () {
//                                 final user = FirebaseAuth.instance.currentUser;
//                                 if (user != null) {
//                                   FirebaseFirestore.instance.collection('conditions and cookies').doc(user.uid).set({
//                                     'user': user.email,
//                                     'conditions': false,
//                                     'notification': isChecked,
//                                   });
//                                 }
//                                 Navigator.of(context).pop();
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                           Container(
//                             width: 1,
//                             height: 30,
//                             color: Colors.grey,
//                           ),
//                           Expanded(
//                             child: TextButton(
//                               child: Text("Accepter"),
//                               onPressed: () {
//                                 final user = FirebaseAuth.instance.currentUser;
//                                 if (user != null) {
//                                   FirebaseFirestore.instance.collection('conditions and cookies').doc(user.uid).set({
//                                     'user': user.email,
//                                     'conditions': true,
//                                     'notification': isChecked,
//                                   });
//                                 }
//                                 Navigator.of(context).pop();
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       );
//     }
//   }
// }