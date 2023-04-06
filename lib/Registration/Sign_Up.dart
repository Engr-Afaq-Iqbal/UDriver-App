import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';
import '../main.dart';
import '../progress_dialog.dart';
import 'Log_In.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool securetxt = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController universityController = TextEditingController();

  validateForm() {
    if (nameController.text.length < 3) {
      Fluttertoast.showToast(msg: "Name must be atleast 4 charecters");
    } else if (!emailController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email is not valid");
    } else if (passwordController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be atleast 6 characters");
    } else if (cnicController.text.length < 13) {
      Fluttertoast.showToast(msg: "cnic must be atleast 13 numbers");
    } else if (numberController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Number is required");
    } else if (universityController.text.isEmpty) {
      Fluttertoast.showToast(msg: "University is required");
    } else {
      saveInfo();
    }
  }

  saveInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Processing Please wait....",
        );
      },
    );
    final User? firebaseUser = (await fAuth
            .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
            .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error:$msg");
    }))
        .user;
    if (firebaseUser != null) {
      Map driverMap = {
        "id": firebaseUser.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "cnic": cnicController.text.trim(),
        "number": numberController.text.trim(),
        "university": universityController.text.trim(),
        "profile":
            "https://firebasestorage.googleapis.com/v0/b/busbyu-926c1.appspot.com/o/bbu.png?alt=media&token=33b9340e-b109-4bd4-a6cc-791b58913243",
      };

      driversRef.child(firebaseUser.uid).set(driverMap);

      currentFirebaseUser = firebaseUser;

      Fluttertoast.showToast(msg: "Account has been Created.");

      SharedPreferences pref = await SharedPreferences.getInstance();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LogIn(),
        ),
      );
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been Created.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white12,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      image: AssetImage(
                        "images/udriver.png",
                      ),
                      fit: BoxFit.cover,
                    )),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Registration",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        hintText: "Name",
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
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: emailController,
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
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
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
                          onTap: () {
                            setState(() {
                              if (securetxt == true) {
                                securetxt = false;
                              } else {
                                securetxt = true;
                              }
                            });
                          },
                          child: securetxt
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Colors.black,
                                )
                              : const Icon(
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
                      height: 10,
                    ),
                    TextField(
                      controller: cnicController,
                      decoration: const InputDecoration(
                        labelText: "CNIC",
                        hintText: "36******",
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
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: "Number",
                        hintText: "Number",
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
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: universityController,
                      decoration: const InputDecoration(
                        labelText: "University",
                        hintText: "University",
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
                    const SizedBox(
                      height: 10,
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
                                "Register",
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
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "Already have an Account?  ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: "LogIn",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.lightBlue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const LogIn(),
                                        ),
                                      )),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
