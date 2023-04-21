import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menifi/components/Anime/AnimeCarousel.dart';
import 'package:menifi/components/Anime/AnimeReviews.dart';
import 'package:menifi/components/Anime/AnimeTrailers.dart';
import 'package:menifi/components/Anime/AnimeTrendingSlider.dart';
import 'package:menifi/components/Anime/ContinueWatchingAnime.dart';
import 'package:menifi/components/Anime/FavouriteAnimeSlider.dart';
import 'package:menifi/components/Anime/PopularAnimeSlider.dart';
import 'package:menifi/components/Anime/TopRatedAnimeSlider.dart';
import 'package:menifi/components/Anime/UpcomingAnimeSlider.dart';
import 'package:menifi/pages/AnimeScreens/AnimeSearchScreen.dart';

import '../../components/CustomDrawer/CustomDrawer.dart';
import '../../components/constants.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
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
          'Anime',
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
                          builder: (context) => const AnimeSearchScreen()));
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
                    AnimeCarousel(),
                    ContinueWatchingAnime(),
                    AnimeTrailers(),
                    PopularAnimeSlider(),
                    AnimeTrendingSlider(),
                    TopRatedAnimeSlider(),
                    FavouriteAnimeSlider(),
                    UpcomingAnimeSlider(),
                    AnimeReviews(),
                  ],
                ),
              ))
        ],
      ),
    ));
  }
}
