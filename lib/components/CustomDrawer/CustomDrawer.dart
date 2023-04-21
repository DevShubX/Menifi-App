import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/pages/AccountScreen/AccountScreen.dart';
import 'package:menifi/pages/AnimeScreens/AnimeScreen.dart';
import 'package:menifi/pages/ComicScreens/ComicScreen.dart';
import 'package:menifi/pages/FavouritesScreen/FavouritesScreen.dart';
import 'package:menifi/pages/Homescreen/HomeScreen.dart';
import 'package:menifi/pages/MangaScreens/MangaScreen.dart';
import 'package:menifi/pages/MovieScreens/MovieScreen.dart';
import 'package:menifi/pages/TVShowScreens/TVShowScreen.dart';
import 'package:menifi/pages/Wishlistscreen/WishlistScreen.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(223, 20, 1, 44)),
          ),
          ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('${_auth.currentUser!.displayName}',
                    style: const TextStyle(
                        fontFamily: 'Gilroy-Bold', fontSize: 18)),
                accountEmail: Text(
                  '${_auth.currentUser!.email}',
                  style: const TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 0, 0)),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage:
                      NetworkImage('${_auth.currentUser?.photoURL}'),
                ),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        opacity: 0.5,
                        image: NetworkImage(BackgroundImage[0]),
                        fit: BoxFit.cover)),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomeScreen()));
                },
                leading: Image.asset(
                  'assets/images/home-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Home",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FavouritesScreem()));
                },
                leading: Image.asset(
                  'assets/images/favourites-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Favourites",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WishListScreen()));
                },
                leading: Image.asset(
                  'assets/images/wishlist-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Wishlist",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => MovieScreen()));
                },
                leading: Image.asset(
                  'assets/images/movie-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Movies",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TVShowScreen()));
                },
                leading: Image.asset(
                  'assets/images/tvshows-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "TV Shows",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AnimeScreen()));
                },
                leading: Image.asset(
                  'assets/images/anime-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Anime",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MangaScreen()));
                },
                leading: Image.asset(
                  'assets/images/manga-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Manga",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ComicScreen()));
                },
                leading: Image.asset(
                  'assets/images/comic-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Comic",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              // ListTile(
              //   onTap: () {},
              //   leading: Image.asset(
              //     'assets/images/music-icon.png',
              //     width: 30,
              //   ),
              //   title: const Text(
              //     "Music",
              //     style: TextStyle(fontFamily: 'Gilroy-Medium'),
              //   ),
              // ),
              const Divider(
                thickness: 2,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountScreen()));
                },
                leading: Image.asset(
                  'assets/images/account-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Account",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              ListTile(
                onTap: () {
                  LogOutUser(context);
                },
                leading: Image.asset(
                  'assets/images/logout-icon.png',
                  width: 30,
                ),
                title: const Text(
                  "Log Out",
                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30))
            ],
          ),
        ],
      ),
    );
  }
}

List<String> BackgroundImage = [
  // "https://img.freepik.com/free-vector/torii-gate-fuji-mountain_52683-44987.jpg?w=1380&t=st=1677920621~exp=1677921221~hmac=3c74a73156b4dda11ef30af719f049c7389a7ed92b10da16eb13bb75e03d5ccb",
  // "https://img.freepik.com/free-vector/gradient-japanese-temple-rock-surrounded-by-water_52683-44984.jpg?w=1380&t=st=1677920640~exp=1677921240~hmac=52fecc9ee5fec3a6ca3b798650b9d263c84ba43ce7c741160f5a289df00639f0",
  // "https://img.freepik.com/free-vector/space-game-background-neon-night-alien-landscape_107791-1624.jpg?size=626&ext=jpg&ga=GA1.2.1480267531.1677593940&semt=sph",
  // "https://img.freepik.com/free-vector/sunset-sunrise-ocean-nature-landscape_33099-2244.jpg?size=626&ext=jpg&ga=GA1.2.1480267531.1677593940&semt=sph",
  // 'https://img.freepik.com/free-vector/night-ocean-landscape-full-moon-stars-shine_107791-7397.jpg?size=626&ext=jpg&ga=GA1.1.1480267531.1677593940&semt=ais',

  "https://img.freepik.com/free-photo/3d-mountain-landscape-against-sunset-sky-with-low-clouds_1048-12442.jpg?w=1060&t=st=1678605884~exp=1678606484~hmac=031f6597780783a943b31318504734ea5f634d895d17d5fb7a900cd8589ff730",
];
