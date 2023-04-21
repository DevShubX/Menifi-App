import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'package:menifi/components/constants.dart';
import 'dart:convert';

class FavouritesScreem extends StatefulWidget {
  const FavouritesScreem({super.key});

  @override
  State<FavouritesScreem> createState() => _FavouritesScreemState();
}

class _FavouritesScreemState extends State<FavouritesScreem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffolKey = new GlobalKey<ScaffoldState>();
  DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ScaffolKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _ScaffolKey,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            "Favourites",
            style: TextStyle(
                fontFamily: 'Gilroy-Bold',
                fontSize: 23,
                color: Color.fromARGB(255, 255, 255, 255)),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: appbar_color,
          leadingWidth: 40,
          leading: Container(
            margin: const EdgeInsets.only(left: 5),
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
        body: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(const Duration(milliseconds: 800), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => super.widget));
            });
          },
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/gradient-bg-5.jpg'),
                  fit: BoxFit.cover,
                )),
              ),
              Positioned(
                child: StreamBuilder(
                    stream: _database
                        .child(
                            'users/${_auth.currentUser!.uid}/favourites/fav_arr')
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List favarr = (snapshot.data!.snapshot.value ?? [])
                            as List<dynamic>;
                        return favarr.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 250,
                                ),
                                itemCount: favarr.length,
                                itemBuilder: (BuildContext context, index) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                              "${favarr[index]['filmPoster'] ?? favarr[index]['anilistPoster']['large']}",
                                              width: 135,
                                              height: 195,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                    width: 135,
                                                    height: 195,
                                                    fit: BoxFit.cover,
                                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                              },
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Container(
                                                    width: 135,
                                                    height: 195,
                                                    color: const Color.fromARGB(
                                                        85, 0, 0, 0),
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive(),
                                                    ),
                                                  );
                                                }
                                              }),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                            "${favarr[index]['type'] != "ANIME" ? favarr[index]['title'] : favarr[index]['title']['romaji']}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                            : const Center(
                                child: Text(
                                  "You have not Added \nAnything yet.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy-Bold', fontSize: 22),
                                ),
                              );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
