import 'package:flutter/material.dart';
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/pages/Homescreen/HomeScreen.dart';
import 'package:menifi/pages/SignupScreen/SignUpScreen.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.only(top: 40),
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Colors.red),
        ));
  }
}

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
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
                    "Login to Your Account",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Bold', fontSize: width * 0.07),
                  ),
                ),
                SignInForm(
                  size: width,
                  formKey: _formkey,
                  email_controller: email_controller,
                  password_controller: password_controller,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
} //// End of the function

class SignInForm extends StatefulWidget {
  SignInForm({
    super.key,
    required this.size,
    required this.formKey,
    this.email_controller,
    this.password_controller,
  });
  final size;
  final formKey;
  final email_controller;
  final password_controller;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool loading = false;
  bool isLoadingGoogle = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(top: 40),
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
                /// Email Box
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter email";
                  } else {
                    return null;
                  }
                },
                controller: widget.email_controller,
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
              ///// Password Box
              padding: EdgeInsets.only(top: 5, bottom: 5),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 27, 27, 27),
              ),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter password";
                  } else {
                    return null;
                  }
                },
                controller: widget.password_controller,
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
            loading
                ? LoadingWidget()
                : CustomSignInButton(
                    size: widget.size,
                    press: () {
                      if (widget.formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        LogInUser(widget.email_controller.text,
                                widget.password_controller.text)
                            .then((user) => {
                                  if (user != null)
                                    {
                                      Future.delayed(
                                          Duration(milliseconds: 300), () {
                                        setState(() {
                                          loading = false;
                                        });
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        HomeScreen()));
                                      }),
                                      popupToast('Welcome'),
                                    }
                                  else
                                    {
                                      setState(() {
                                        loading = false;
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
              margin: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?  ",
                    style: TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SignUpScreen()));
                    },
                    child: const Text(
                      "Sign up",
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

class CustomSignInButton extends StatelessWidget {
  const CustomSignInButton({
    super.key,
    required this.size,
    required this.press,
  });

  final size;
  final VoidCallback press;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: size,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
                topRight: Radius.circular(25),
                topLeft: Radius.circular(10)),
            color: Colors.red),
        alignment: Alignment.center,
        child: const Text(
          "Sign In",
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
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        child: Column(
          children: [
            Image.asset(
              "assets/images/M-Logo.png",
              width: size * 0.35,
            ),
          ],
        ),
      ),
    );
  }
}
