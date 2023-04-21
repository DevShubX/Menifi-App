import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/components/TVShows/PopularTVShowsSlider.dart';
import 'package:menifi/components/TVShows/TVOnTheAirSlider.dart';
import 'package:menifi/components/TVShows/TVshowsEpisodesSlider.dart';
import 'package:menifi/pages/TVShowScreens/OnTheAirTvShowsScreen.dart';
import 'package:shimmer/shimmer.dart';

import '../MovieScreens/MovieDetailScreen.dart';

class TVShowDetailsScreen extends StatefulWidget {
  const TVShowDetailsScreen(
      {super.key, required this.tvshowId, this.tvshowName, this.tvshowImage});
  final tvshowName;
  final tvshowImage;
  final String tvshowId;

  @override
  State<TVShowDetailsScreen> createState() => _TVShowDetailsScreenState();
}

class _TVShowDetailsScreenState extends State<TVShowDetailsScreen> {
  late Map data = {};
  bool isLoading = true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List sources = [];
  List subtitles = [];
  late Map sourcedata;
  late String TvShowId = "";

  Future getTvshowInfo(String tvshowId) async {
    http.Response response = await http.get(Uri.parse(
        'https://menifi-api.vercel.app/api/info/flixhq/tv/${tvshowId}'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);

        TvShowId = data['movieId']
            .toString()
            .split('-')[data['movieId'].toString().split('-').length - 1];
        isLoading = false;
      });
    } else if (response.statusCode == 404 || response.statusCode == 400) {}
  }

  Future addTvShowToFav(userId, Map tvshowDetails, tvshowString) async {
    DatabaseReference dbref =
        FirebaseDatabase.instance.ref().child('users/$userId/favourites/');
    List<dynamic> arr = [];
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/favourites/fav_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List favArr = snapshot.value as List;

          for (var snap in favArr) {
            if (snap['movieId'] != tvshowDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({...tvshowDetails, 'movieStreamingLink': tvshowString});
          await dbref.set({'fav_arr': arr});
        } else {
          arr.add({...tvshowDetails, 'movieStreamingLink': tvshowString});
          await dbref.set({'fav_arr': arr});
        }
      });
      popupToast("Added To Favourites");
    } catch (error) {
      print(error);
    }
  }

  Future addTvshowToWishlist(userId, Map tvhsowDetails, tvshowString) async {
    DatabaseReference dbref =
        FirebaseDatabase.instance.ref().child('users/$userId/wishlist/');
    List<dynamic> arr = [];
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/wishlist/wishlist_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List wishlistArr = snapshot.value as List;

          for (var snap in wishlistArr) {
            if (snap['movieId'] != tvhsowDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({...tvhsowDetails, 'movieStreamingLink': tvshowString});
          await dbref.set({'wishlist_arr': arr});
        } else {
          arr.add({...tvhsowDetails, 'movieStreamingLink': tvshowString});
          // print('No data available');
          await dbref.set({'wishlist_arr': arr});
        }
      });
      popupToast("Added To Wishlist");
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    if (widget.tvshowId != null) {
      getTvshowInfo(widget.tvshowId);
    }
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
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.red, size: 30),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 185,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.tvshowImage,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 185,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                                width: 125,
                                height: 200,
                                fit: BoxFit.cover,
                                'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      "${widget.tvshowName}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Gilroy-Medium', fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.red)),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 360,
                            child: Image.network(
                              '${data['backgroundImage'] ?? ""}',
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.6),
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                    height: 360,
                                    fit: BoxFit.cover,
                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: -5,
                            child: Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)),
                                  color: Color.fromARGB(255, 28, 28, 28)),
                            )),
                        Positioned(
                            top: 300,
                            left: 40,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    addTvshowToWishlist(_auth.currentUser!.uid,
                                        data, "tv/${widget.tvshowId}");
                                  },
                                  child: Image.asset(
                                    'assets/images/wishlist-icon.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Wishlist",
                                  style: TextStyle(fontFamily: 'Gilroy-Medium'),
                                )
                              ],
                            )),
                        Positioned(
                            top: 300,
                            right: 30,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    addTvShowToFav(_auth.currentUser!.uid, data,
                                        "tv/${widget.tvshowId}");
                                    // print("tv/${widget.tvshowId}");
                                    // Ex :- tv/watch-house-online-hd-39423
                                  },
                                  child: Image.asset(
                                    'assets/images/favourites-icon.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Favourite',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy-Medium',
                                  ),
                                )
                              ],
                            )),
                        Positioned(
                            top: 150,
                            child: Container(
                              alignment: Alignment.center,
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  '${data['filmPoster'] ?? ""}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        width: 125,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            )),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Color.fromARGB(255, 28, 28, 28)),
                      child: Column(
                        /// Main column start from here
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${data['title'] ?? ""}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Gilroy-Bold', fontSize: 25),
                          ),
                          Container(
                            height: 4,
                            width: 200,
                            margin: const EdgeInsets.only(top: 20),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, index) =>
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                    )),
                          ),
                          GestureDetector(
                            // onTap: () {
                            //   Navigator.push(context,
                            //       MaterialPageRoute(builder: (context) {
                            //     return FutureBuilder(
                            //         future: getMovieLink(
                            //             '${data['episodes'][0]['id']}',
                            //             '${data['movieId']}'),
                            //         builder: (context, snapshot) {
                            //           if (snapshot.connectionState ==
                            //               ConnectionState.done) {
                            //             return MovieVidePlayer(
                            //               sources: sources,
                            //               subtitles: subtitles,
                            //             );
                            //           } else {
                            //             return const Center(
                            //               child: CircularProgressIndicator
                            //                   .adaptive(),
                            //             );
                            //           }
                            //         });
                            //   }));
                            // },
                            child: Container(
                              //// Watch now button
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(69, 255, 0, 0),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow,
                                      size: 35,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: const Text('Watch',
                                          style: TextStyle(
                                              fontFamily: 'Gilroy-Bold',
                                              fontSize: 22)),
                                    )
                                  ]),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 30),
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Duration',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 235, 235, 235),
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 17),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '${data['duration'] ?? "NA"}',
                                      style: const TextStyle(
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                              255, 235, 235, 235)),
                                    )
                                  ],
                                ),
                                const VerticalDivider(
                                  thickness: 2,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Release Date',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 235, 235, 235),
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 17),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '${data['releaseDate'] ?? "NA"}',
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 235, 235, 235),
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                                const VerticalDivider(
                                  thickness: 2,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Rating',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 235, 235, 235),
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 17),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '${data['rating'] ?? "NA"}',
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 235, 235, 235),
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 12, right: 12),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Overview',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${data['description'] ?? "NA"}'
                                      .trim()
                                      .replaceAll("\n", ""),
                                  textAlign: TextAlign.left,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 12, right: 12),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Production',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${data['production'] ?? "NA"}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 15),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 12, right: 12),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Country',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${data['country'] ?? "NA"}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 15),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, right: 12, left: 12),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Genres',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data['genres']!.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    90, 175, 175, 175)),
                                            height: 20,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.only(
                                                top: 2,
                                                left: 10,
                                                right: 10,
                                                bottom: 1),
                                            child: Text(
                                              "${data['genres'][index]}"
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontFamily: 'Gilroy-Bold',
                                                  fontSize: 15),
                                            ));
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, right: 12, left: 12),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Casts',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 20,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data['casts']!.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    90, 175, 175, 175)),
                                            height: 20,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.only(
                                                top: 1,
                                                left: 10,
                                                right: 10,
                                                bottom: 1),
                                            child: Text(
                                              "${data['casts'][index]}",
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontFamily: 'Gilroy-Bold',
                                                  fontSize: 15),
                                            ));
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TvShowId != ""
                        ? TVShowsEpisodeSlider(
                            tvshowid: TvShowId,
                            tvshowDetails: data,
                            tvshowName: "${data['title'] ?? ""}",
                            tvshowFullId: "${data['movieId'] ?? ""}")
                        : Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const CircularProgressIndicator.adaptive()),
                    const PopularTVShowsSlider(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
