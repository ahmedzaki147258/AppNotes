import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:appnote/component/alert.dart';
import 'package:appnote/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class AddNotes extends StatefulWidget {
  const AddNotes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddNotesState();
  }
}

class _AddNotesState extends State<AddNotes> {
  late Reference ref;
  File? file;
  // ignore: prefer_typing_uninitialized_variables
  var title, note, imageurl;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  CollectionReference nodesref = FirebaseFirestore.instance.collection("notes");

  addNotes(context) async {
    if (file == null) {
      return AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.leftSlide,
          title: "Error",
          body: const Text("Please choose Image."),
          btnOkOnPress: () {},
          btnOkColor: Colors.brown)
        .show();
    }
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      showLoading(context);
      formdata.save();
      await ref.putFile(file!);
      imageurl = await ref.getDownloadURL();
      await nodesref.add({
        "title": title,
        "note": note,
        "image url": imageurl,
        "userid": FirebaseAuth.instance.currentUser!.uid,
      }).then((value) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false, );
      }).catchError((e) {
        print("$e");
      });
    }
  }

  var serverToken =
      "AAAAokYWM9U:APA91bEI01SBPTbTfxOuGp3Pl7LAhsVq27uDry9_fnlLcTbzGljvEddwzW8RmX-4psB7jkChfhtM0l4jvF37aHYKOEPwOBcQ8_tbsr1hd3p049BUl6XBt4A0wRN75CucLhMSoYSUaAbU";
  sendNotfiy(String title, String body, String id) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body.toString(),
            'title': title.toString(),
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': id.toString(),
            'fname': "Ahmed",
            'lname': "zaki",
            'age': 15,
          },
          'to': "/topics/ahmed",
          //"fXAGs-TbSfyt5W3EdLRZZX:APA91bEe8wMSjBdnc3jzBOFpLndfZCIGSI3TBezAHJOxqX5evGKzUBTaiOgeDpjBioKdU9LrFIdPo7uIk9uP77hmJ-0wLlHrM5Gqit79BWlr5ShYM-o26Zyx4e8EqHY8NrQ1aG02P_k3",
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Form(
            key: formstate,
            child: Column(children: [
              TextFormField(
                validator: (val) {
                  if (val!.length > 30) {
                    return "Title can't to be larger than 30 letter";
                  } else if (val.length < 2) {
                    return "Title can't to be less than 2 letter";
                  }
                  return null;
                },
                onSaved: (val) {
                  title = val;
                },
                maxLength: 30,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  label: Text("Title Note"),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              TextFormField(
                validator: (val) {
                  if (val!.length > 255) {
                    return "Notes can't to be larger than 255 letter";
                  } else if (val.length < 10) {
                    return "Notes can't to be less than 10 letter";
                  }
                  return null;
                },
                onSaved: (val) {
                  note = val;
                },
                minLines: 1,
                maxLines: 3,
                maxLength: 400,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  label: Text("Note"),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  showBattomSheet(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Add Image for Note",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // Button border radius
                ),
                elevation: 5.0,
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () async {
                  await addNotes(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Add Note",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white),
                ),
                color: Colors.blue, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // Button border radius
                ),
                elevation: 5.0,
              ),
            ]),
          ),
          const SizedBox(
            height: 20,
          ),
          MaterialButton(
              onPressed: () async {
                await sendNotfiy("Welcome", "A5oya A7la msa 3lik", "id");
              },
              child: const Text("send Notify")),
          MaterialButton(
              onPressed: () async {
                await FirebaseMessaging.instance.subscribeToTopic("ahmed");
              },
              child: const Text("subscribe Topic")),
          MaterialButton(
              onPressed: () async {
                await FirebaseMessaging.instance.unsubscribeFromTopic("ahmed");
              },
              child: const Text("Un subscribe Topic")),
        ]),
      ),
    );
  }

  showBattomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 180,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Please choose image",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Container(
                height: 5,
              ),
              InkWell(
                onTap: () async {
                  var picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    file = File(picked.path);
                    var rand = Random().nextInt(1000000);
                    var nameimage = "$rand" + basename(picked.path);
                    ref =
                        FirebaseStorage.instance.ref("Images").child(nameimage);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.photo_album,
                          size: 25,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text("from Gallery",
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ],
                    )),
              ),
              InkWell(
                onTap: () async {
                  var picked =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    file = File(picked.path);
                    var rand = Random().nextInt(1000000);
                    var nameimage = "$rand" + basename(picked.path);
                    ref =
                        FirebaseStorage.instance.ref("Images").child(nameimage);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.camera,
                          size: 25,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text("from Camera",
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ],
                    )),
              ),
            ]),
          );
        });
  }
}
