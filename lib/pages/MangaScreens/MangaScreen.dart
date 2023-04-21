import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'package:menifi/components/Manga/FavouriteMangaSlider.dart';
import 'package:menifi/components/Manga/MangaCarousel.dart';
import 'package:menifi/components/Manga/MangaReviews.dart';
import 'package:menifi/components/Manga/PopularMangaSlider.dart';
import 'package:menifi/components/Manga/TopMangaSlider.dart';
import 'package:menifi/components/Manga/TrendingMangaSlider.dart';
import 'package:menifi/pages/MangaScreens/MangaSearchScreen.dart';

import '../../components/constants.dart';

class MangaScreen extends StatefulWidget {
  const MangaScreen({super.key});

  @override
  State<MangaScreen> createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      key: _ScaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Manga',
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
                          builder: (context) => const MangaSearchScreen()));
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
                    image: AssetImage('assets/images/gradient-bg-5.jpg'),
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
                MangaCarousel(),
                TrendingMangaSlider(),
                PopularMangaSlider(),
                TopMangaSlider(),
                FavouriteMangaSlider(),
                MangaReviews()
              ],
            )),
          ),
        ],
      ),
    ));
  }
}
