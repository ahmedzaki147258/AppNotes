import 'package:appnote/authentication/login.dart';
import 'package:appnote/crud/addnote.dart';
import 'package:appnote/crud/editnotes.dart';
import 'package:appnote/crud/viewnote.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference noderef = FirebaseFirestore.instance.collection("notes");
  getUser(){
    var user=FirebaseAuth.instance.currentUser;
    print(user!.email);
  }



  initalMessage()async{
    var message = await FirebaseMessaging.instance.getInitialMessage();
    if(message!=null) {
      Navigator.of(context).pushNamed("addnotes");
    }
  }

  requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
}
  final _fbm= FirebaseMessaging.instance;
  @override
  void initState() {
    _fbm.getToken().then((token) {
      print("===============================Token===============================");
      print(token);
      print("===============================Token===============================");
    });

    FirebaseMessaging.onMessage.listen((event) {
      print("===============================notification===============================");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: "${event.notification!.title}",
        body: Text("${event.notification!.body}") ,
        btnOkOnPress: () {},
      ).show();
      //Navigator.of(context).pushNamed("addnotes");
      print("Title : ${event.notification!.title}");
      print("Body : ${event.notification!.body}");
      print("ID : ${event.data['id']}");
      print("FirstName : ${event.data['fname']}");
      print("ListName : ${event.data['lname']}");
      print("Age : ${event.data['age']}");
      print("===============================notification===============================");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.of(context).pushNamed("addnotes");
    });

    requestPermission();
    initalMessage();
    // getUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(onPressed: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text(
                          'Confirm Logout!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Title color
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Are you sure you want to logout from the application?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Content color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.red, // Button text color
                          ),
                        ),
                        onPressed: () async{
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false, );
                          },
                      ),

                      MaterialButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.blue, // Button text color
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                    elevation: 5.0, // Dialog shadow
                  );
                },
              );
            }, icon: const Icon(Icons.logout))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: 'Add note',
            child: const Icon(Icons.add),onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNotes()));

        }),
        body: FutureBuilder(
            future: noderef.where("userid",isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, i) {
                  return Dismissible(
                    onDismissed: (diretion)async{
                      await noderef.doc(snapshot.data.docs[i].id).delete();
                      await FirebaseStorage.instance.refFromURL(snapshot.data.docs[i]['image url']).delete().then((value) {
                        print("================================================");
                        print("Deleted");
                      });
                    },
                      key: UniqueKey(),
                      child: ListNotes(
                        notes: snapshot.data.docs[i],
                        docid: snapshot.data.docs[i].id,
                      )
                  ) ;
                });
          }
          return const Center(child: CircularProgressIndicator(),) ;
        })
        ),
      );
  }
}


class ListNotes extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final notes,mdw,docid;
  // ignore: use_key_in_widget_constructors
  const ListNotes({this.notes,this.mdw,this.docid});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ViewNotes(notes: notes,);
        }));
      },
      child: Card(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Image.network(
                  "${notes['image url']}",
                  fit: BoxFit.fill,
                  height: 100,
                ),
              ),

              Expanded(
                //width: mdw-10,
                flex: 2,
                child: ListTile(
                  title: Text("${notes['title']}",style: const TextStyle(fontSize: 20),),
                  subtitle: Text("${notes['note']}",style: const TextStyle(fontSize: 14),),
                  trailing: IconButton(onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return EditNotes(docid: docid,list: notes,);
                    }));
                  }, icon: const Icon(Icons.edit)),
                ),),
            ],
          )),
    );
  }
}

