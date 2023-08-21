import 'package:appnote/authentication/login.dart';
import 'package:appnote/component/background.dart';
import 'package:appnote/homepage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appnote/component/alert.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late String myusername, mypassword, myemail;
  signUp() async {
    var formdata=formstate.currentState;
    if(formdata!.validate()){
      formdata.save();
      try {
        showLoading(context);
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: myemail,
          password: mypassword,
        );
        print("dfcfvsdrfv : $userCredential");
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: "Error",
            body: const Text("password is to weak"),
            btnCancelOnPress: () {},
          ).show();
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.infoReverse,
            animType: AnimType.leftSlide,
            title: "Error",
            body: const Text("The account already exists for that email."),
            btnCancelOnPress: () {},
          ).show();
        }
      } catch (e) {
        print(e);
      }
    }
    else {
      print("Not valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        widget: SingleChildScrollView(
          child: Form(
            key: formstate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    onSaved: (val){
                      myusername = val!;
                    },
                    validator: (val){
                      if(val!.length>100){
                        return "username can't to be larger than 100 letter";
                      }
                      else if(val.length<2){
                        return "username can't to be less than 2 letter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Username"
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    onSaved: (val){
                      myemail = val!;
                    },
                    validator: (val){
                      if(val!.length>100){
                        return "E-mail can't to be larger than 100 letter";
                      }
                      else if(val.length<2){
                        return "E-mail can't to be less than 2 letter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "E-mail"
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    onSaved: (val){
                      mypassword = val!;
                    },
                    validator: (val){
                      if(val!.length>100){
                        return "password can't to be larger than 100 letter";
                      }
                      else if(val.length<4){
                        return "password can't to be less than 4 letter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Password"
                    ),
                    obscureText: true,
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: MaterialButton(
                    onPressed: () async{
                      UserCredential? response = await signUp();
                      if(response!=null){
                        await FirebaseFirestore.instance.collection("users").add({
                          "username": myusername,
                          "email" : myemail,
                        });
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false, );
                      }
                      else{
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: "Error",
                          body: const Text("Sign up Failed"),
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80.0),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 136, 34),
                            Color.fromARGB(255, 255, 177, 41)
                          ]
                        )
                      ),
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        "SIGN UP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: GestureDetector(
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))
                    },
                    child: const Text(
                      "Already Have an Account? Sign in",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA)
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}