import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseAPI() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    // Configuration pour Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon'); // Assurez-vous d'avoir une icône dans le dossier res/drawable

    // Initialisation globale
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Assurez-vous d'utiliser un ID de canal valide
      'your_channel_name',
      icon: 'app_icon',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // ID de notification
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token :$fCMToken');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }
}

//
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class FirebaseAPI{
//   final _firebasemessaging = FirebaseMessaging.instance;
//   late final FirebaseMessaging _messaging;
//
//   Future<void> registerNotification() async{
//     _messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//
//     );
//   }
//
//   Future<void> handleBackGroundMessage(RemoteMessage message) async{
//     print('Title : ${message.notification?.title}');
//     print('Body : ${message.notification?.body}');
//     print('payload : ${message.data}');
//   }
//   Future<void> initNotifications() async{
//     await _firebasemessaging.requestPermission();
//     final fCMToken = await _firebasemessaging.getToken();
//     print('Token :$fCMToken');
//     FirebaseMessaging.onBackgroundMessage((message) => handleBackGroundMessage(message));
//   }
// }

