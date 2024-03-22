import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/ADMIN/AdminPage.dart';
import 'package:myapp/ApartmentDescriptionWidget.dart';
import 'package:myapp/LoginPage.dart';
import 'package:myapp/Models/PriceModel.dart';
import 'package:myapp/RerservationPage.dart';
import 'package:myapp/api/firebase_api.dart';
import 'package:myapp/calendar_page.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/messUserView.dart';
import 'package:myapp/services/authentification.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

String _googleEmail = "unknown" ;
final List<String> UserList = [];
enum SettingsOption {
  option1,
  option2,
  // Ajoutez d'autres options si nécessaire
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Utilisez les options par défaut
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseAPI().initNotifications();
    runApp( MyApp());
  } catch (e) {
    print("Erreur lors de l'initialisation de Firebase: $e");
    // Vous pouvez également afficher une erreur à l'utilisateur si nécessaire
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: AuthService().userChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user != null) {
              _googleEmail = user.email.toString();
              UserList.add(_googleEmail);
              print("MY USER IS $_googleEmail");
              if (_googleEmail == 'starsjason43@gmail.com') {
                return const AdminPage();
              } else {
                return const HomePage();
              }
            } else {
              print("NO USER");
              return const LoginPage();
            }
          }
          // Si la connexion est toujours en cours, vous pouvez afficher un indicateur de chargement
          return const CircularProgressIndicator();
        },
      ),
    );
  }

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}
class _HomePageState extends State<HomePage> {
  final List<String> imagePaths = [
    'images/appart.jpg',
    'images/cuisine.webp',
    'images/douche.webp',
    'images/douche2.webp',
    'images/elevator.webp',
    'images/salon.webp',
    'images/salon2.webp',
    'images/salon3.webp',
    'images/view.webp',
    // Ajoutez d'autres chemins d'images selon vos besoins
  ];
  double _currentIndex = 0;
  Future<void> checkConditions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userid = user.uid;
      final collectionRef = FirebaseFirestore.instance.collection('conditions and cookies');
      final doc = await collectionRef.doc(userid).get();

      if (!doc.exists || doc.data()?['conditions'] != true) {
        displayDialogue(); // Conditions non acceptées ou document inexistant
      } else {
        conditionsChecked = true; // Conditions acceptées
      }
    } else {
      displayDialogue(); // Utilisateur non connecté
    }
  }

  @override
  void initState() {
    super.initState();
    checkConditions();
  }
  bool? conditionsChecked = false;
  bool? isChecked = false;

  // Fonction pour vérifier les conditions
  // Future<void> checkConditions() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final userid = user.uid;
  //     final collectionRef = FirebaseFirestore.instance.collection('conditions and cookies');
  //     final doc = await collectionRef.doc(userid).get();
  //
  //     if (!doc.exists || doc.data()?['conditions'] != true) {
  //       displayDialogue(); // Conditions non acceptées ou document inexistant
  //     } else {
  //       conditionsChecked = true; // Conditions acceptées
  //     }
  //   } else {
  //     displayDialogue(); // Utilisateur non connecté
  //   }
  // }

  void displayDialogue(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                padding: EdgeInsets.all(15.0),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Conditions Générales d'Utilisation de l'Application Vakapp",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.0),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black, fontSize: 16.0),
                                children: <TextSpan>[
                                  TextSpan(text: "1. Acceptation des Conditions\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "En téléchargeant ou en utilisant l'application Vakapp, vous acceptez d'être lié par les présentes Conditions Générales d'Utilisation (CGU). Si vous n'acceptez pas ces conditions, vous ne pouvez pas utiliser l'application.\n\n"),
                                  TextSpan(text: "2. Description du Service\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Vakapp permet aux utilisateurs de réserver des hébergements meublés pour des durées allant jusqu'à 90 jours. Les hébergements sont situés au 45 bd de la Croisette à Cannes 06400 et au 5 rue Victor Cousin 06400 Cannes. Les tarifs varient selon la durée et les dates de réservation.\n\n"),
                                  TextSpan(text: "3. Réservation et Paiement\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Les réservations se font via l'application avec paiement par carte bancaire. Des réductions via codes promos peuvent être appliquées. Toute réservation est sujette à une confirmation par Vakapp.\n\n"),
                                  TextSpan(text: "4. Annulation et Remboursement\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Les annulations sont possibles jusqu'à 7 jours avant la date de réservation. Une charge de compensation de 30% du montant payé ne sera pas remboursable.\n\n"),
                                  TextSpan(text: "5. Utilisation de l'Hébergement\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "L'hébergement est limité à 3 occupants et est classé en Meublé 2 étoiles. Il est équipé de tous les conforts nécessaires pour un séjour agréable.\n\n"),
                                  TextSpan(text: "6. Responsabilité des Locataires\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Les locataires sont responsables de tous les dommages causés pendant leur séjour. Ils doivent maintenir l'hébergement dans un état correct.\n\n"),
                                  TextSpan(text: "7. Modification des Conditions\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Vakapp se réserve le droit de modifier les présentes CGU à tout moment. Les utilisateurs seront informés des modifications et devront accepter les nouvelles conditions pour continuer à utiliser l'application.\n\n"),
                                  TextSpan(text: "8. Confidentialité et Données Personnelles\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "La protection de vos données est importante pour Vakapp. Notre Charte de protection des données à caractère personnel décrit comment nous collectons et utilisons vos données.\n\n"),
                                  TextSpan(text: "9. Contact et Réclamations\n", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Pour toute question ou réclamation, vous pouvez contacter Vakapp au +33650793898 ou par email à vakapp.loc@gmail.com.\n\n"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      subtitle: Text(
                        "Je consens à recevoir des offres commerciales et promotionnelles de VAKAPP par SMS, e-mail ou notifications push.",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: isChecked,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      checkColor: Colors.blue,
                      activeColor: Colors.white,
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            child: Text("Refuser"),
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                FirebaseFirestore.instance.collection('conditions and cookies').doc(user.uid).set({
                                  'user': user.email,
                                  'conditions': false,
                                  'notification': isChecked,
                                });
                              }
                              // Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: TextButton(
                            child: Text("Accepter"),
                            onPressed: () {
                              conditionsChecked = true;
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                FirebaseFirestore.instance.collection('conditions and cookies').doc(user.uid).set({
                                  'user': user.email,
                                  'conditions': true,
                                  'notification': isChecked,
                                });
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40), // Hauteur personnalisée de la bannière
          child: AppBar(
              backgroundColor: Colors.blue,
              title: Row(children: [
                PopupMenuButton<SettingsOption>(
                  onSelected: (SettingsOption result) {
                    // Gérez vos actions ici
                    switch (result) {
                      case SettingsOption.option1:
                        print('Option 1 sélectionnée');
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return  ReservationPage(googleEmail: _googleEmail,);
                                }));
                        break;
                      case SettingsOption.option2:
                        print('Option 2 sélectionnée');
                        break;
                    // Ajoutez d'autres cas si nécessaire
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SettingsOption>>[
                    const PopupMenuItem<SettingsOption>(
                      value: SettingsOption.option1,
                      child: Text('Voir vos reservations'),
                    ),
                    // const PopupMenuItem<SettingsOption>(
                    //   value: SettingsOption.option2,
                    //   child: Text('(Pas implementé)'),
                    // ),
                    // Ajoutez d'autres éléments de menu ici si nécessaire
                  ],
                  icon: const Icon(Icons.settings),
                ),
                const SizedBox(width: 80,),
                const Text(
                  "VakApp",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                const SizedBox(width: 80,),
                IconButton(icon: const Icon(Icons.logout),
                  onPressed: () async{
                    await AuthService().signOutGoogle();
                  },)
              ],)
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image: const AssetImage('images/plage.jpg'),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Center(child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Bordure de l'image
                  child: SizedBox(
                      width: 380, // Largeur souhaitée de l'image
                      height: 320, // Hauteur souhaitée de l'image
                      child: Stack(
                        alignment: Alignment.bottomCenter, // Aligner les enfants de la pile en bas au centre
                        children: [
                          PageView.builder(
                              itemCount: imagePaths.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index.toDouble();
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.asset(imagePaths[index], fit: BoxFit.cover);
                              }),
                          Positioned(bottom: 10
                            ,child:DotsIndicator(dotsCount: imagePaths.length,position: _currentIndex.toInt()),),]
                        ,)
                  ),)
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // Espacement à gauche et à droite

                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Text(
                        "Studio Exceptionnel à Cannes",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                      Row(children: [const Text("Cannes",
                        style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.bold),),
                        const SizedBox(width: 100,),
                        IconButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => messUserView(googleEmail: _googleEmail,)),);}, icon: const Icon(FontAwesomeIcons.commentDots,size: 30,),
                        ),
                        const SizedBox(width: 20,),
                        IconButton(
                          icon:const Icon(Icons.calendar_month_outlined,color: Colors.blue,size: 35),
                          onPressed: ()  {
                            checkConditions();
                            if(conditionsChecked == false) {
                              print("condition est false");
                              // Afficher la fenêtre de dialogue des conditions
                              //  checkConditions();
                            }
                            else {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return CalendarPage(username: _googleEmail);
                                      }
                                  )
                              );
                            }
                          },),
                        const SizedBox(width: 20,),
                        /*IconButton(onPressed: (){
                          FlutterPhoneDirectCaller.callNumber('+0781432124');
                        }, icon: const Icon(Icons.call,color: Colors.blue,size: 35,)),*/
                      ],),
                      const ApartmentDescriptionWidget(),
                      ],
                  ),
                ),
              ],),
          ),
        )
    );
  }
}
