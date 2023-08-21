import 'dart:io';
import 'dart:math';
import 'package:appnote/component/alert.dart';
import 'package:appnote/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditNotes extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final docid, list;
  const EditNotes({Key? key, this.docid, this.list}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EditNotesState();
  }
}

class _EditNotesState extends State<EditNotes> {
  late Reference ref;
  File? file;
  // ignore: prefer_typing_uninitialized_variables
  var title, note, imageurl;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  CollectionReference nodesref=FirebaseFirestore.instance.collection("notes");

  editNotes(context)async{
    var formdata = formstate.currentState;
    if(file==null) {
      if(formdata!.validate()){
        showLoading(context);
        formdata.save();
        await nodesref.doc(widget.docid).update({
          "title": title,
          "note" : note,
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false, );
        }).catchError((e){
          print("$e");
        });
      }
    }
    else{
      if(formdata!.validate()){
        showLoading(context);
        formdata.save();
        await ref.putFile(file!);
        imageurl = await ref.getDownloadURL();
        await nodesref.doc(widget.docid).update({
          "title": title,
          "note" : note,
          "image url" : imageurl,
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false, );
        }).catchError((e){
          print("$e");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Form(
            key: formstate,
            child: Column(children: [
              TextFormField(

                validator: (val){
                  if(val!.length>30){
                    return "Title can't to be larger than 30 letter";
                  }
                  else if(val.length<2){
                    return "Title can't to be less than 2 letter";
                  }
                  return null;
                },
                onSaved: (val){
                  title=val;
                },
                initialValue: widget.list['title'] ,
                maxLength: 30,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  label: Text("Title Note"),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              TextFormField(
                validator: (val){
                  if(val!.length>255){
                    return "Notes can't to be larger than 255 letter";
                  }
                  else if(val.length<10){
                    return "Notes can't to be less than 10 letter";
                  }
                  return null;
                },
                onSaved: (val){
                  note=val;
                },
                initialValue: widget.list['note'] ,
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
                  "Edit Image for Note",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // Button border radius
                ),
                elevation: 5.0, // Shadow
              ),
              const SizedBox(height: 20,),
              MaterialButton(
                onPressed: () async {
                await editNotes(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Edit Note",
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                ),
                color: Colors.blue, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // Button border radius
                ),
                elevation: 5.0, // Shadow
              )
            ]),
          )
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
              const Text("Edit image",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Container(height: 5,),
              InkWell(
                onTap: ()async{
                  var picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if(picked!=null){
                    file=File(picked.path);
                    var rand=Random().nextInt(1000000);
                    var nameimage = "$rand"+basename(picked.path);
                    ref = FirebaseStorage.instance.ref("Images").child(nameimage);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(children: const [
                      Icon(Icons.photo_album,size: 25,),
                      SizedBox(width: 15,),
                      Text("from Gallery", style: TextStyle(fontSize: 20, )),
                    ],)
                ),
              ),
              InkWell(
                onTap: ()async{
                  var picked = await ImagePicker().pickImage(source: ImageSource.camera);
                  if(picked!=null){
                    file=File(picked.path);
                    var rand=Random().nextInt(1000000);
                    var nameimage = "$rand"+basename(picked.path);
                    ref = FirebaseStorage.instance.ref("Images").child(nameimage);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(children: const [
                      Icon(Icons.camera,size: 25,),
                      SizedBox(width: 15,),
                      Text("from Camera", style: TextStyle(fontSize: 20, )),
                    ],)
                ),
              ),
            ]),
          );
        });
  }
}
