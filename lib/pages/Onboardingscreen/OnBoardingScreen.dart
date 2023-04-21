import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menifi/pages/Signinscreen/SignInScreen.dart';
import 'package:rive/rive.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late RiveAnimationController _btnAnimationController;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    _btnAnimationController.dispose();
    super.dispose();
  }

  List<Container>? images = [
    Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/movies-collage.gif"),
            fit: BoxFit.cover),
      ),
    ),
    Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/anime-collage.gif"),
            fit: BoxFit.cover),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return images![index];
              }),
          SafeArea(
            child: Column(children: [
              const Spacer(),
              Container(
                decoration:
                    const BoxDecoration(color: Colors.transparent, boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(188, 15, 14, 14),
                      blurRadius: 10.0,
                      spreadRadius: 10.0,
                      offset: Offset(0, 4)),
                ]),
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          "Welcome to Menifi",
                          style: TextStyle(
                              fontSize: 36,
                              color: Color.fromARGB(255, 255, 0, 0),
                              fontFamily: 'Gilroy-Heavy'),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 7),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: (const Text(
                          "Your all in one place to stream movies,tv shows ,music,anime and read manga and comics.",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy-Medium',
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: AnimatedBtn(
                        btnAnimationColtroller: _btnAnimationController,
                        press: () {
                          _btnAnimationController.isActive = true;
                          Future.delayed(Duration(milliseconds: 900), () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()));
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}

class GetStartedButton extends StatelessWidget {
  const GetStartedButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.amber,
      onTap: () {},
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.red),
        alignment: Alignment.center,
        child: const Text(
          "Get Started",
          style: TextStyle(
              fontFamily: "Gilroy-Bold", color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class AnimatedBtn extends StatelessWidget {
  const AnimatedBtn({
    Key? key,
    required RiveAnimationController btnAnimationColtroller,
    required this.press,
  })  : _btnAnimationColtroller = btnAnimationColtroller,
        super(key: key);

  final RiveAnimationController _btnAnimationColtroller;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        height: 64,
        width: 260,
        child: Stack(
          children: [
            // Just a button no animation
            // Let's fix that
            RiveAnimation.asset(
              "assets/RiveAssets/button.riv",
              // Once we restart the app it shows the animation
              controllers: [_btnAnimationColtroller],
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Get Started",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "Gilroy-Bold"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
