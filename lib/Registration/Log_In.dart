import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:u_driver/Home.dart';
import 'package:u_driver/Registration/Sign_Up.dart';

import '../global.dart';
import '../progress_dialog.dart';


class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool securetxt = true;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();


  validateForm() {
    if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email is not valid");
    } else if (passwordTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password is required");
    } else {
      loginDriverNow();
    }
  }

  loginDriverNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Processing Please wait....",
          );
        });
    final User? firebaseUser = (await fAuth
        .signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
        .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error:$msg");
    }))
        .user;

    if (firebaseUser != null) {
      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Login Succesfull");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Home(),),);
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error Occured during Login");
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white12,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(90),
                ),
              ),
              child: Center(
                child: Container(
                  height: 220,
                  width: 250,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/udriver.png",),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.only(left: 20,right: 20,),
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat"
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: emailTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "email",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: passwordTextEditingController,
                    decoration:  InputDecoration(
                      labelText: "Password",
                      hintText: "Password",

                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                      suffixIcon: InkWell(
                        onTap: (){
                          setState(() {
                            if(securetxt==true){
                              securetxt = false;
                            }
                            else{
                              securetxt = true;
                            }
                          });
                        },
                        child: securetxt? const Icon(
                          Icons.visibility_off,
                          color: Colors.black,
                        ):
                        const Icon(
                          Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    obscureText: securetxt,

                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 18,
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.lightBlue,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ]),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            validateForm();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  RichText(
                    text:  TextSpan(
                        text: "Don't have an Account?  ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "SignUp",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.lightBlue,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SignUp(),),)
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),

          ]),
        ),
      ),
    );
  }
}
