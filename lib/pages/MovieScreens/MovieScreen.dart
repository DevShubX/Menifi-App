import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'package:menifi/components/Movies/ContinueWatchingMoviesSlider.dart';
import 'package:menifi/components/Movies/MoviesCarousel.dart';
import 'package:menifi/components/Movies/NowPlayingMoviesSlider.dart';
import 'package:menifi/components/Movies/TopRatedMoviesSlider.dart';
import 'package:menifi/components/Movies/TrendingMoviesSlider.dart';
import 'package:menifi/components/Movies/UpComingMoviesSlider.dart';
import 'package:menifi/pages/MovieScreens/MovieSearchSScreen.dart';

import '../../components/Movies/PopularMoviesSlider.dart';
import '../../components/constants.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
              'Movies',
              style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: appbar_color,
            leadingWidth: 40,
            leading: Container(
              margin: EdgeInsets.only(left: 5),
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
                              builder: (BuildContext context) =>
                                  MovieSearchScreen()));
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget));
                  });
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const MoviesCarousel(),
                      const ContinueWatchingMoviesSlider(),
                      const PopularMoviesSlider(),
                      const TopRatedMoviesSlider(),
                      const TrendingMoviesSlider(),
                      const NowPlayinMoviesSlider(),
                      const UpComingMoviesSlider(),
                      Container(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
