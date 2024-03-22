import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:myapp/ClassObj/CombineData.dart';
import 'package:myapp/ClassObj/ReservObj.dart';
import 'package:myapp/ClassObj/PriceObj.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({super.key, required this.username,});
  final String username;



  @override
  State<CalendarPage> createState() => _CalendarPageState();

}
class _CalendarPageState extends State<CalendarPage>{

  late String username ;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<ReservObj> nonValidDateRanges = [];
  List<PriceObj> priceobjList = [];
  // Map<DateTime, Map<DateTime, double>> prices = {};

  late bool _needReload;
  late StreamSubscription<QuerySnapshot> priceDateSubscription;
  late bool acceptedRules;
  int _selectedNumberOfPeople = 1; // Valeur initiale
  int _nbdays = 0; // Valeur initiale


  String formatDateForUrl(DateTime? date) {
    String? year = date?.year.toString();
    String? month = date?.month.toString().padLeft(2, '0');
    String? day = date?.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  Future<bool> isEventIdPresentInFirestore(String eventId) async {
    final collection = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await collection.where('id', isEqualTo: eventId).get();

    // Si la requête retourne au moins un document, l'ID est déjà présent
    return querySnapshot.docs.isNotEmpty;
  }
  Future<void> fetchAndProcessICalendar(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final iCalendar = ICalendar.fromString(response.body);
      // Supposons que `iCalendar.data` contienne une liste d'événements
      for (var vevent in iCalendar.data) {
        DateTime start = DateTime.parse((vevent['dtstart'].dt).toString());
        DateTime end = DateTime.parse((vevent['dtend'].dt).toString());
        final eventId = vevent['uid'];
        final bool eventIdExists = await isEventIdPresentInFirestore(eventId);
        if(!eventIdExists){
          // Création d'un nouvel objet ReservObj pour chaque événement
          final reservObj = ReservObj(
              id: vevent['uid'], // Utilisation de l'UID comme identifiant unique
              start: start,
              end: end,
              approved: 1, // Supposons que toutes les réservations sont approuvées
              user: "Airbnb User" // Mettez une valeur par défaut ou extrayez des données si possible
          );

          CollectionReference userReservations = FirebaseFirestore.instance
              .collection('users');
          try {
            DocumentReference docRef = await userReservations.add({
              'end': end,
              'start': start,
              'approved': 1,
              'user': "Airbnb User"
            });
            // Si l'ajout à Firestore réussit, ajoutez la plage de dates à la liste locale
            setState(() {
              nonValidDateRanges.add(reservObj);
            });
          } catch (e) {
            print('Erreur lors de l\'ajout de la plage de dates à Firestore: $e');
          }
        }
      }
    } else {
      print('ERREUR');
      throw Exception('Failed to load iCalendar file');
    }
  }
  void _showDialogWithLink(String title, double totalprice,String start, String end,String nbpeople) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final String url = "https://checkout.lodgify.com/david-perez-0eec6f/fr/?currency=EUR&_gl=1*lf5p8o*_ga*MTk4NTE5NDY2Mi4xNzA4MzQ0MzIw*_ga_GTQS7L994W*MTcwODc5NzIzOC43LjAuMTcwODc5NzIzOS4wLjAuMA..*_ga_GBHF8BEZM3*MTcwODc5NzIzOC43LjAuMTcwODc5NzIzOS4wLjAuMA..#/542835/$start,$end,$nbpeople/-";
        return AlertDialog(
          title: Text(title),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Définit le style par défaut pour TextSpan
              children: [
                TextSpan(
                    text: "Vos dates sont bien disponibles! \nLe prix à payer sera approximativement de : $totalprice €. \n\nPour finir cette réservation veuillez cliquer sur "
                ),
                TextSpan(
                  text: "Vakapp.com",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () async {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      print('Could not launch $url');
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> updateDateRanges() async {
    CollectionReference userReservations = FirebaseFirestore.instance
        .collection('users');

    try {
      // Récupérez toutes les plages de dates de Firestore
      QuerySnapshot snapshot = await userReservations.get();
      List<ReservObj> firestoreDateRanges = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        DateTime start = (doc['start'] as Timestamp).toDate();
        DateTime end = (doc['end'] as Timestamp).toDate();
        int approved = doc['approved'] ;
        String id = doc.id;
        String user = doc['user'];
        ReservObj elt = ReservObj(start: start, end: end, approved: approved, user: user,id: id);
        firestoreDateRanges.add(elt);
      }

      // Mettez à jour la liste locale avec les plages de dates manquantes
      setState(() {
        for (var range in firestoreDateRanges) {
          // print("ma range est ${range.start}");
          if (!nonValidDateRanges.contains(range)) {
            nonValidDateRanges.add(range);
          }
        }
      });

      // Affichez les plages de dates pour le débogage
      // for (var dateRange in nonValidDateRanges) {
        // print('Start Date: ${dateRange.start}, End Date: ${dateRange.end}, Approved: ${dateRange.approved}, User: ${dateRange.user}');
      // }
    } catch (e) {
      print('Erreur lors de la récupération des plages de dates de Firestore: $e');
    }
  }
  Future<void> loadPricesFromFirestore() async {
    try {
      // Récupération des documents de la collection 'priceDate'
      var collection = FirebaseFirestore.instance.collection('priceDate');
      var querySnapshot = await collection.get();

      // Mise à jour de la map 'prices' avec les données de Firestore
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        DateTime startDate = (data['startDate'] as Timestamp).toDate();
        // print('ma start $startDate');
        DateTime endDate = (data['endDate'] as Timestamp).toDate();
        double price = data['price'];
        PriceObj elt  = PriceObj(firstdate: startDate, lastdate: endDate, price: price);
        if(!priceobjList.contains(elt)) {
          priceobjList.add(
              PriceObj(firstdate: startDate, lastdate: endDate, price: price));
        }
      }
    } catch (e) {
      print("Erreur lors du chargement des prix depuis Firestore: $e");
      // Gérer l'erreur ici
    }
  }

  @override
  void initState() {
    super.initState();
    username = widget.username;
    _needReload = false;
    fetchAndProcessICalendar("https://www.airbnb.fr/calendar/ical/1057173382575549680.ics?s=793da2fbf0ea9e69fd75e4fd48645f04");
    loadPricesFromFirestore();
    updateDateRanges();
    checkAndDisplayDialog();

  }
  Future<bool> verifierConditionsUtilisateur() async {
    // Obtenir l'utilisateur actuel
    User? utilisateur = FirebaseAuth.instance.currentUser;

    if (utilisateur != null) {
      // Obtenir l'UID de l'utilisateur
      String uid = utilisateur.uid;

      // Récupérer le document de l'utilisateur dans Firestore
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('conditions and cookies')
          .doc(uid)
          .get();

      // Vérifier si le document existe et contient le champ 'conditions'
      if (docSnapshot.exists && docSnapshot.data() is Map) {
        Map data = docSnapshot.data() as Map;
        return data['conditions'] == true; // Retourne true si 'conditions' est true
      }
    }
    return false; // Retourne false si l'utilisateur n'est pas connecté ou si le champ 'conditions' n'est pas true
  }

  bool? isChecked = false;
  void checkAndDisplayDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userid = user.uid;
      final collectionRef = FirebaseFirestore.instance.collection('conditions and cookies');

      final doc = await collectionRef.doc(userid).get();
      if (!doc.exists) {
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
                                  Navigator.of(context).pop();
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
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    FirebaseFirestore.instance.collection('conditions and cookies').doc(user.uid).set({
                                      'user': user.email,
                                      'conditions': true,
                                      'notification': isChecked,
                                    });
                                  }
                                  Navigator.of(context).pop();
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
    }
  }

  void reloadCalendar() {
    setState(() {
      _needReload = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage(username: username),), // this mymainpage is your page to refresh
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget _customDisabledBuilder(BuildContext context, DateTime day, DateTime focusedDay) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(color: Colors.grey),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: Divider(color: Colors.grey, thickness: 1.5),
            ),
          ],
        ),
      );
    }
    Widget _customTodayBuilder(BuildContext context, DateTime day, DateTime focusedDay) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }

    bool isDateValid(DateTime date) {
      for (final range in nonValidDateRanges) {
        if (date.isAfter(range.start) && date.isBefore(range.end) && range.approved == 1){
          return false;
        }
      }
      return true;
    }

    void addNonValidDateRange(DateTime startDate, DateTime endDate,String username2) async {
      // final newRange = ReservObj(start: startDate, end: endDate, approved: 2, user: username, );

      CollectionReference userReservations = FirebaseFirestore.instance
          .collection('users');

      try {
        DocumentReference docRef = await userReservations.add({
          'end': endDate,
          'start': startDate,
          'approved': 2,
          'user': username2
        });

        final newRange = ReservObj(
            id: docRef.id, // Stockez l'ID du document
            start: startDate,
            end: endDate,
            approved: 2,
            user: username2
        );
        // Si l'ajout à Firestore réussit, ajoutez la plage de dates à la liste locale
        setState(() {
          nonValidDateRanges.add(newRange);
        });

        // // Affichez les plages de dates pour le débogage
        // for (var dateRange in nonValidDateRanges) {
        //   print('Start Date: ${dateRange.start}, End Date: ${dateRange.end}, Approved: ${dateRange.approved}, User: ${dateRange.user}');
        // }
      } catch (e) {
        print('Erreur lors de l\'ajout de la plage de dates à Firestore: $e');
      }
    }



    double? getPriceFromList(DateTime date, List<PriceObj> periodprices)
    {
      for(var period in periodprices){
        if( date.isAtSameMomentAs(period.firstdate)||date.isAfter(period.firstdate) && date.isBefore(period.lastdate.add(Duration(days: 1))))
          return period.price;
      }
      return null;
    }



    double calculateTotalPrice(DateTime start, DateTime end, List<PriceObj> periodPrices) {
      double totalPrice = 0.0;
      int nb = 0;
      for (DateTime date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
        nb+=1;
        double? price = getPriceFromList(date, periodPrices);
        if (price != null) {
          totalPrice += price;
        }
      }
      setState(() {
        _nbdays = nb;
      });
      totalPrice+=160+(_selectedNumberOfPeople-1)*(10*_nbdays)+(1.88*_nbdays*_selectedNumberOfPeople);
      return totalPrice;
    }

    void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }

    void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {

      if (start != null && end != null) {
        bool isValid = true;
        for (DateTime date = start; date.isBefore(end.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
          if (!isDateValid(date)) {
            isValid = false;
            break;
          }
        }
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certaines dates dans la selection ne sont pas disponibles\n Veuillez choisir une autre plage de date.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        double totalPrice = calculateTotalPrice(start, end, priceobjList);

        // Affichez le prix total
        // Par exemple, en utilisant un SnackBar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prix total: \$${totalPrice.toStringAsFixed(2)}'),
            duration: Duration(seconds: 4),
          ),
        );

      }
      setState(() {
        _selectedDay = null;
        _rangeStart = start;
        _rangeEnd = end;
        _focusedDay = focusedDay;
      });

    }
    void _onFormatChanged(CalendarFormat format)
    {
      setState(() {
        if(_calendarFormat !=format){
          _calendarFormat = format;
        }
      });
    }
    CalendarBuilders customCalendarBuilders(List<PriceObj> pricelist/*Map<DateTime, Map<DateTime, double>> periodPrices*/) {


      return CalendarBuilders(
        todayBuilder: _customTodayBuilder,
        disabledBuilder: _customDisabledBuilder,
        markerBuilder: (context, date, events) {
          // double? price = getPriceForDate(date, periodPrices);
          double? price = getPriceFromList(date, pricelist);
          if (price != null) {
            return Positioned(
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  price.toStringAsFixed(0)+'€',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            );
          }
          return null;
        },
        // ... autres builders ...
      );
    }

    bool areListsPriceEqual(List<PriceObj> list1, List<PriceObj> list2) {
      if (list1.length != list2.length) {
        return false;
      }
      for (int i = 0; i < list1.length; i++) {
        if (list1[i].price != list2[i].price || list1[i].firstdate != list2[i].firstdate || list1[i].lastdate != list2[i].lastdate) { // Comparez selon les champs pertinents
          return false;
        }
      }
      return true;
    }
    bool areListsReservEqual(List<ReservObj> list1, List<ReservObj> list2) {
      // Vérifiez si de nouveaux éléments ont été ajoutés avec approved == 1
      if (list2.length > list1.length) {
        for (int i = list1.length; i < list2.length; i++) {
          if (list2[i].approved == 1) {
            return false;
          }
        }
      }

      for (int i = 0; i < list1.length; i++) {
        // Vérifiez si les éléments existants ont changé de 0 ou 2 à 1
        if ((list1[i].approved == 0 || list1[i].approved == 2) && list2[i].approved == 1) {
          return false;
        }
        if(list1[i].approved == 1 && (list2[i].approved == 0 || list2[i].approved == 2)) {
          return false;
        }
      }
      return true;
    }



    Stream<CombinedData> getCombinedStream() {
      var stream1 = FirebaseFirestore.instance.collection('priceDate').snapshots();
      var stream2 = FirebaseFirestore.instance.collection('users').snapshots();

      return Rx.combineLatest2(stream1, stream2, (QuerySnapshot snapshot1, QuerySnapshot snapshot2) {
        // Combinez les données des deux snapshots ici
        return CombinedData(snapshot1, snapshot2);
      });
    }


    return Scaffold(
        appBar: const MyAppBar(),
        body: StreamBuilder<CombinedData>(
          stream:  getCombinedStream(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Center(child: CircularProgressIndicator());
            // }
            //
            // if (snapshot.hasError) {
            //   return Center(child: Text("Erreur de chargement des données"));
            // }
            //
            // if (!snapshot.hasData) {
            //   return Center(child: Text("Aucune donnée disponible"));
            // }
            /// DECOMMENTER CE CODE POUR ACTIVER LE RELOAD MAIS IL FAUT LE CORRIGER
            // if (snapshot.hasData) {
            //   // Exemple de vérification de changement
            //   var newPriceList = snapshot.data!.snapshot1.docs.map((doc) => PriceObj.fromDocument(doc)).toList();
            //   var newReservList = snapshot.data!.snapshot2.docs.map((doc) => ReservObj.fromDocument(doc)).toList();
            //
            //   if (!areListsPriceEqual(newPriceList, priceobjList) || !areListsReservEqual(nonValidDateRanges,newReservList)) { // areListsEqual est une fonction hypothétique
            //     _needReload = true;
            //   } else {
            //     _needReload = false;
            //   }
            // }
            return Column(
              children: [
                //
                PeriodSection(rangeStart: _rangeStart, rangeEnd: _rangeEnd),
                if (_needReload == true)
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.yellow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Des périodes ont été ajoutées.\nVeuillez recharger le calendrier."),
                        ElevatedButton(
                          onPressed: reloadCalendar,
                          child: Text("Recharger"),
                        ),
                      ],
                    ),
                  ),

                DropdownButton<int>(
                  value: _selectedNumberOfPeople,
                  icon: const Icon(Icons.person),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedNumberOfPeople = newValue!;
                    });
                  },
                  items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
                TableCalendar(

                  rowHeight: 70,
                  headerStyle: const HeaderStyle(formatButtonVisible: false , titleCentered: true),
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day)=> isSameDay(_selectedDay,day),

                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,

                  enabledDayPredicate: (day) {
                    for (var dateRange in nonValidDateRanges) {
                      // print("start : ${dateRange.start} , end ${dateRange.end}");
                      if (day.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
                          day.isBefore(dateRange.end.add(const Duration(days: 1))) && (dateRange.approved == 1 )) {
                        return false;
                      }
                    }
                    return true;
                  },

                  // calendarBuilders: customCalendarBuilders(prices, _selectedDay),
                  calendarBuilders: customCalendarBuilders(priceobjList),
                  // calendarFormat: _calendarFormat,
                  calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                  onFormatChanged: _onFormatChanged,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  onDaySelected: _onDaySelected,

                  onRangeSelected: _onRangeSelected,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,

                ),
                ElevatedButton(
                  onPressed: () {
                    if (_rangeStart == null || _rangeEnd == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez sélectionner une plage de dates valide.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                    if (_needReload) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Des modifications ont été apportées. Veuillez recharger le calendrier."),
                          action: SnackBarAction(
                            label: "Recharger",
                            onPressed: reloadCalendar,
                          ),
                        ),
                      );
                    }
                    else {
                      String start = formatDateForUrl(_rangeStart);
                      String end = formatDateForUrl(_rangeEnd);
                      String nbpeople = _selectedNumberOfPeople.toString();
                      double totalprice = calculateTotalPrice(_rangeStart!, _rangeEnd!, priceobjList);
                      // double tot = totalprice+160+(_selectedNumberOfPeople-1)*(10*_nbdays);
                      // print("LEEEEE PRIXXX EST $_nbdays");
                      addNonValidDateRange(_rangeStart!, _rangeEnd!,username);
                      _showDialogWithLink(
                          'Succès',
                           totalprice,
                      start,
                      end,
                      nbpeople);
                      print('$_rangeStart  et  $_rangeEnd');
                    }
                  },
                  child: const Text('Je reserve !'),
                )
              ],
            );
          }
        )
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.grey[800],
          size: 30,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.blue,
      title: const Row(
        children: [
          SizedBox(
            width: 70,
          ),
          Text('VakApp',
            style: TextStyle(color: Colors.white,
                fontSize: 30),
          ),
        ],
      ),
    );
  }
}


class PeriodSection extends StatelessWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const PeriodSection({super.key,
    required this.rangeStart,
    required this.rangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('E d MMM');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Depart',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  rangeStart != null
                      ? dateFormat.format(rangeStart!)
                      : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Container(
              height: 60,
              width: 1,
              color: Colors.grey[350],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Retour',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  rangeEnd != null
                      ? dateFormat.format(rangeEnd!)
                      : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
        ),
      ],
    );
  }
}
