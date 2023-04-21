import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'dart:async';
import 'dart:convert';

import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/components/Homescreen/CustomCarousel.dart';
import 'package:menifi/components/Homescreen/PopularComicsSlider.dart';
import 'package:menifi/components/Homescreen/PopularMangasSlider.dart';
import 'package:menifi/components/Homescreen/PopularMoviesSlider.dart';
import 'package:menifi/components/Homescreen/PopularTVShowsSlider.dart';
import 'package:menifi/components/Homescreen/TrendingAnimeSlider.dart';
import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth? _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _ScaffolKey = new GlobalKey<ScaffoldState>();

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
        key: _ScaffolKey,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appbar_color,
          leadingWidth: 40,
          leading: Container(
            margin: EdgeInsets.only(left: 5),
            child: GestureDetector(
              onTap: () {
                _ScaffolKey.currentState!.openDrawer();
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
              margin: EdgeInsets.only(right: 5),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${_auth?.currentUser?.photoURL}',
                ),
                radius: 20,
              ),
            )
          ],
        ),
        drawer: CustomDrawer(),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/gradient-bg.jpg'),
              fit: BoxFit.cover,
            )),
          ),
          RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(milliseconds: 800), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => super.widget));
              });
            },
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  CustomCarouselSlider(),
                  PopularMoviesSlider(),
                  PopularTVShowsSlider(),
                  TrendingAnimeSlider(),
                  PopularMangasSlider(),
                  PopularComicSlider(),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
