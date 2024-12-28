import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notifications
  Future<void> initNotification() async {
    //request permission from user (prompt user)
    await _firebaseMessaging.requestPermission();

    //fetch the FCM token for this device
    final FCMToken = await _firebaseMessaging.getToken();

    //print the FCM Token
    print(FCMToken);
  }

  //function to handle received messages

  //function to initialize foreground and backround settings
}
