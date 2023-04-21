import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/components/Comic/PopularComicSlider.dart';
import 'package:menifi/components/Comic/PopularIssueSlider.dart';
import 'package:menifi/components/Comic/PopularStoryArcSlider.dart';
import 'package:menifi/components/Homescreen/PopularComicsSlider.dart';
import 'package:menifi/pages/ComicScreens/ComicSearchScreen.dart';

import '../../components/CustomDrawer/CustomDrawer.dart';
import '../../components/constants.dart';

class ComicScreen extends StatefulWidget {
  const ComicScreen({super.key});

  @override
  State<ComicScreen> createState() => _ComicScreenState();
}

class _ComicScreenState extends State<ComicScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      extendBodyBehindAppBar: true,
      key: _ScaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Comic',
          style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appbar_color,
        leadingWidth: 40,
        leading: Container(
          margin: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              _ScaffoldKey.currentState!.openDrawer();
            },
            child: Image.asset(
              "assets/images/M-Logo.png",
              width: 10,
              height: 10,
            ),
          ),
        ),
        actions: [
          Container(
            width: 35,
            height: 35,
            margin: const EdgeInsets.only(right: 20),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ComicSearchScreen()));
                },
                child: Image.asset('assets/images/search-icon.png')),
          ),
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                '${_auth.currentUser?.photoURL}',
              ),
              radius: 20,
            ),
          )
        ],
      ),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/gradient-bg-7.png'),
                    fit: BoxFit.cover)),
          ),
          RefreshIndicator(
              onRefresh: () {
                return Future.delayed(const Duration(milliseconds: 800), () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => super.widget));
                });
              },
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    SizedBox(
                      height: 50,
                    ),
                    ComicSliderPopular(),
                    PopularIssueSlider(),
                    PopularStoryArcSlider()
                  ],
                ),
              ))
        ],
      ),
    ));
  }
}
