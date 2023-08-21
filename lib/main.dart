import 'package:appnote/authentication/login.dart';
import 'package:appnote/homepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

late bool islogin;
Future backgroundMessage(RemoteMessage message)async{
  print("===============================background Message===============================");
  print("${message.notification!.body}");
  print("===============================background Message===============================");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessage);

  var user = FirebaseAuth.instance.currentUser;
  if(user==null) {
    islogin=false;
  } else {
    islogin=true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Notes',
      debugShowCheckedModeBanner: false,
      home: islogin == false ? const LoginScreen() : const HomePage(),
      theme: ThemeData(
        // fontFamily: "NotoSerif",
          primaryColor: Colors.blue,
          textTheme: const TextTheme(
            headline6: TextStyle(fontSize: 20, color: Colors.white),
            headline5: TextStyle(fontSize: 30, color: Colors.blue),
            bodyText2: TextStyle(fontSize: 20, color: Colors.black),
          )),
    );
  }
}
