import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/pages/Homescreen/HomeScreen.dart';
import 'package:menifi/pages/Signinscreen/SignInScreen.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController email_controller = TextEditingController();

  TextEditingController password_controller = TextEditingController();

  TextEditingController name_controller = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      print("Failed to pick image");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                MenifiName(
                  size: width,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Create Your Account",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Bold', fontSize: width * 0.07),
                  ),
                ),
                SignUpForm(
                  size: width,
                  email_controller: email_controller,
                  password_controller: password_controller,
                  name_controller: name_controller,
                  formKey: formKey,
                  image: image,
                  avatar_press: () async {
                    await pickImage();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  SignUpForm({
    super.key,
    required this.size,
    required this.name_controller,
    required this.email_controller,
    required this.password_controller,
    required this.formKey,
    required this.image,
    required this.avatar_press,
  });
  final size;
  final name_controller;
  final email_controller;
  final password_controller;
  final GlobalKey<FormState> formKey;
  final File? image;
  final VoidCallback avatar_press;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String errorAvatar = '';
  bool isLoading = false;
  bool isLoadingGoogle = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(top: 20),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 27, 27, 27),
              ),
              child: TextFormField(
                //// Name
                controller: widget.name_controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name cannot be empty";
                  } else {
                    return null;
                  }
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontFamily: "Gilroy-Medium", fontSize: 15),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Name",
                    prefixIcon: Icon(
                      Icons.account_circle_rounded,
                      color: Colors.red,
                      size: widget.size * 0.06,
                    )),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 27, 27, 27),
              ),
              child: TextFormField(
                /// Email
                controller: widget.email_controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter email";
                  } else {
                    return null;
                  }
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontFamily: "Gilroy-Medium", fontSize: 15),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    prefixIcon: Icon(
                      Icons.mail_rounded,
                      color: Colors.red,
                      size: widget.size * 0.06,
                    )),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 27, 27, 27),
              ),
              child: TextFormField(
                /// Password
                controller: widget.password_controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a password";
                  } else {
                    return null;
                  }
                },
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                style: TextStyle(fontFamily: "Gilroy-Medium", fontSize: 15),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.red,
                      size: widget.size * 0.06,
                    )),
              ),
            ),
            GestureDetector(
              onTap: widget.avatar_press,
              child: Container(
                padding: EdgeInsets.only(top: 0, bottom: 10),
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    widget.image == null
                        ? Image.asset(
                            "assets/images/add-image.png",
                            width: 40,
                            height: 40,
                          )
                        : Image.file(
                            widget.image!,
                            width: 40,
                            height: 40,
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Choose a avatar",
                      style:
                          TextStyle(fontFamily: "Gilroy-Medium", fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? LoadingWidget()
                : CustomSignUpButton(
                    size: widget.size,
                    press: () {
                      if (widget.image == null) {
                        Fluttertoast.showToast(
                            msg: "Please choose a avatar",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 18.0);
                      }
                      if (widget.formKey.currentState!.validate() &&
                          widget.image != null) {
                        setState(() {
                          isLoading = true;
                        });
                        CreateUserAccount(
                                widget.name_controller.text,
                                widget.email_controller.text,
                                widget.password_controller.text,
                                widget.image)
                            .then((user) => {
                                  if (user != null)
                                    {
                                      Future.delayed(
                                          Duration(milliseconds: 300), () {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen()));
                                      }),
                                      popupToast('Welcome'),
                                    }
                                  else
                                    {
                                      setState(() {
                                        isLoading = false;
                                      }),
                                    }
                                });
                      }
                    },
                  ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  const Expanded(
                      child: Divider(
                    thickness: 3,
                  )),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      "or continue with",
                      style:
                          TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 17),
                    ),
                  ),
                  const Expanded(
                      child: Divider(
                    thickness: 3,
                  ))
                ],
              ),
            ),
            isLoadingGoogle
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    margin: const EdgeInsets.only(top: 20),
                    child: const CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                    ))
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoadingGoogle = true;
                      });
                      SignInWithGoogle(context).then((user) => {
                            if (user != null)
                              {
                                Future.delayed(Duration(milliseconds: 300), () {
                                  setState(() {
                                    isLoadingGoogle = false;
                                  });

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomeScreen()));
                                }),
                                popupToast('Welcome'),
                              }
                            else
                              {
                                setState(() {
                                  isLoadingGoogle = false;
                                })
                              }
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 27, 27, 27),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          border: Border.all(
                              color: const Color.fromARGB(255, 85, 85, 85))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.only(top: 25),
                      child: Image.asset(
                        "assets/images/Google.png",
                        width: 33,
                        height: 33,
                      ),
                    ),
                  ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account  ",
                    style: TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SignInScreen()));
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          fontSize: 15,
                          color: Colors.red),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomSignUpButton extends StatelessWidget {
  CustomSignUpButton({super.key, required this.size, required this.press});

  final size;
  final VoidCallback press;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: size,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.only(top: 15),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
                topRight: Radius.circular(25),
                topLeft: Radius.circular(10)),
            color: Colors.red),
        alignment: Alignment.center,
        child: const Text(
          "Sign up",
          style: TextStyle(
              fontFamily: "Gilroy-Bold", color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class MenifiName extends StatelessWidget {
  const MenifiName({super.key, required this.size});

  final size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        child: Column(
          children: [
            Image.asset(
              "assets/images/M-Logo.png",
              width: size * 0.25,
            ),
          ],
        ),
      ),
    );
  }
}
