import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Anime/AnimeAdditionalVideos.dart';
import 'package:menifi/components/Anime/AnimeCharacters.dart';
import 'package:menifi/components/Anime/AnimeEpisodesSlider.dart';
import 'package:menifi/components/Anime/AnimeRelatedPhotos.dart';
import 'package:menifi/components/Anime/AnimeReviewMal.dart';
import 'package:menifi/components/Anime/PopularAnimeSlider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../components/Anime/GogoAnimeDetails.dart';
import '../../components/Firebase/FirebaseMethods.dart';
import '../MovieScreens/MovieDetailScreen.dart';

class AnimeDetailsScreen extends StatefulWidget {
  const AnimeDetailsScreen(
      {super.key,
      required this.animeLink,
      required this.animeImageUrl,
      required this.animeName});
  final animeLink;
  final animeImageUrl;
  final animeName;
  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var anilistResponse;
  var gogoResponse;
  bool isLoading = true;
  int selectedIndex = 0;
  bool showMoreText = false;
  Future getAnimeInfo(String animelink) async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/getanime?link=$animelink'));

    setState(() {
      anilistResponse = json.decode(response.body)![0]['anilistResponse'];
      gogoResponse = json.decode(response.body)![0]['gogoResponse'];
      isLoading = false;
    });
  }

  Future addAnimeToFav(userId, Map animeDetails, animeString) async {
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
            if (snap['id'] != animeDetails['id']) {
              arr.add(snap);
            }
          }
          arr.add({...animeDetails, 'animePageLink': animeString});
          await dbref.set({'fav_arr': arr});
        } else {
          arr.add({...animeDetails, 'animePageLink': animeString});
          await dbref.set({'fav_arr': arr});
        }
      });
      popupToast("Added To Favourites");
    } catch (error) {
      // print(error);
    }
  }

  Future addAnimeToWish(userId, Map animeDetails, animeString) async {
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
            if (snap['id'] != animeDetails['id']) {
              arr.add(snap);
            }
          }
          arr.add({...animeDetails, 'animePageLink': animeString});
          await dbref.set({'wishlist_arr': arr});
        } else {
          arr.add({...animeDetails, 'animePageLink': animeString});
          // print('No data available');
          await dbref.set({'wishlist_arr': arr});
        }
      });
      popupToast("Added To Wishlist");
    } catch (error) {
      // print(error);
    }
  }

  @override
  void initState() {
    if (widget.animeLink != null) {
      getAnimeInfo(widget.animeLink);
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
                          widget.animeImageUrl,
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
                      "${widget.animeName}",
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
            : anilistResponse != "NONE"
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 360,
                                child: Image.network(
                                  '${anilistResponse['anilistBannerImage'] ?? anilistResponse['anilistPoster']['extraLarge']}',
                                  fit: BoxFit.cover,
                                  opacity: const AlwaysStoppedAnimation(0.6),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        height: 320,
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
                                        addAnimeToWish(
                                            _auth.currentUser!.uid,
                                            anilistResponse,
                                            "/animes${widget.animeLink}");
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
                                      style: TextStyle(
                                          fontFamily: 'Gilroy-Medium'),
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
                                        addAnimeToFav(
                                            _auth.currentUser!.uid,
                                            anilistResponse,
                                            "/animes${widget.animeLink}");
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
                                      '${anilistResponse['anilistPoster']['extraLarge']}',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                    '${anilistResponse['title']['romaji'] ?? anilistResponse['title']['english'] ?? anilistResponse['title']['userPreferred']}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        fontSize: 25),
                                  ),
                                  Container(
                                    height: 4,
                                    width: 200,
                                    margin: const EdgeInsets.only(top: 20),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 4,
                                        itemBuilder: (BuildContext context,
                                                index) =>
                                            Container(
                                              alignment: Alignment.centerRight,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                  color: anilistResponse[
                                                                  'anilistPoster']
                                                              ['color'] !=
                                                          null
                                                      ? Color(int.parse(
                                                          anilistResponse['anilistPoster']
                                                                  ['color']
                                                              .toString()
                                                              .replaceAll(
                                                                  "#", "0XFF")))
                                                      : const Color.fromARGB(
                                                          255, 255, 0, 0),
                                                  borderRadius:
                                                      BorderRadius.circular(25)),
                                            )),
                                  )
                                ])),
                        Container(
                          width: double.maxFinite,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 20, left: 10),
                          height: 20,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: anilistResponse['genre'].length,
                            itemBuilder: (context, index) {
                              return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          90, 175, 175, 175)),
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.only(
                                      top: 3, left: 10, right: 10, bottom: 1),
                                  child: Text(
                                    '${anilistResponse['genre'][index]}'
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy-Bold',
                                      fontSize: 13,
                                      color: Color.fromARGB(255, 233, 233, 233),
                                    ),
                                  ));
                            },
                          ),
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
                                    'Status',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${anilistResponse['status'] ?? "NA"}',
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 235, 235, 235)),
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
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${anilistResponse['season'] ?? "NA"}'
                                    " "
                                    '${anilistResponse['released'].toString()}',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
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
                                    'Score',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${anilistResponse['averageScore'] ?? "NA"}',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DefaultTabController(
                          length: 2,
                          child: TabBar(
                              indicatorColor: anilistResponse['anilistPoster']
                                          ['color'] !=
                                      null
                                  ? Color(int.parse(
                                      anilistResponse['anilistPoster']['color']
                                          .toString()
                                          .replaceAll("#", "0XFF")))
                                  : const Color.fromARGB(255, 255, 0, 0),
                              onTap: (value) {
                                setState(() {
                                  selectedIndex = value;
                                });
                              },
                              tabs: const [
                                Tab(
                                  text: 'Details',
                                ),
                                Tab(
                                  text: 'Episodes',
                                )
                              ]),
                        ),
                        selectedIndex == 0
                            ? Column(
                                children: [
                                  Container(
                                    /// Overview Container
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 12, right: 12),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Overview',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 231, 231, 231),
                                              fontFamily: 'Gilroy-Bold',
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          Bidi.stripHtmlIfNeeded(
                                                  "${anilistResponse['description'] ?? "NA"}")
                                              .trim()
                                              .replaceAll("\n", ""),
                                          textAlign: TextAlign.left,
                                          maxLines: showMoreText ? null : 6,
                                          overflow: showMoreText
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 14),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showMoreText = !showMoreText;
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: !showMoreText
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          'Read More',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Gilroy-Medium',
                                                              color: anilistResponse['anilistPoster']
                                                                          [
                                                                          'color'] !=
                                                                      null
                                                                  ? Color(int.parse(anilistResponse['anilistPoster']
                                                                          [
                                                                          'color']
                                                                      .toString()
                                                                      .replaceAll(
                                                                          "#",
                                                                          "0XFF")))
                                                                  : const Color.fromARGB(
                                                                      255,
                                                                      255,
                                                                      0,
                                                                      0)),
                                                        ),
                                                        const Icon(Icons
                                                            .arrow_drop_down_sharp)
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text('Show Less',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Gilroy-Medium',
                                                                color: anilistResponse['anilistPoster']
                                                                            [
                                                                            'color'] !=
                                                                        null
                                                                    ? Color(int.parse(anilistResponse['anilistPoster']
                                                                            [
                                                                            'color']
                                                                        .toString()
                                                                        .replaceAll(
                                                                            "#",
                                                                            "0XFF")))
                                                                    : const Color.fromARGB(
                                                                        255,
                                                                        255,
                                                                        0,
                                                                        0))),
                                                        const Icon(Icons
                                                            .arrow_drop_up_sharp)
                                                      ],
                                                    ),
                                            ))
                                      ],
                                    ),
                                  ),

                                  AnimeCharacters(
                                    malId: anilistResponse['malId'],
                                  ),

                                  AnimeReviewMal(
                                    malId: anilistResponse['malId'],
                                    boxColor: anilistResponse['anilistPoster']
                                                ['color'] !=
                                            null
                                        ? Color(int.parse(
                                                anilistResponse['anilistPoster']
                                                        ['color']
                                                    .toString()
                                                    .replaceAll("#", "0XFF")))
                                            .withOpacity(0.5)
                                        : const Color.fromARGB(255, 32, 32, 32),
                                  ),

                                  AnimeAdditionalVideos(
                                    malId: anilistResponse['malId'],
                                  ),
                                  AnimeRelatedPhotos(
                                    malId: anilistResponse['malId'],
                                  ),
                                  // /// Overview Container
                                  const PopularAnimeSlider(),
                                ],
                              )
                            : AnimeEpisodesSlider(
                                gogoResponse: gogoResponse,
                                anilistResponse: anilistResponse,
                                animeLink: widget.animeLink,
                                animeName:
                                    '${anilistResponse['title']['romaji'] ?? anilistResponse['title']['english'] ?? anilistResponse['title']['userPreferred']}',
                                anilistListId:
                                    '${anilistResponse['id']}'.toString())
                      ],
                    ),
                  )
                : GOGOAnimeDetails(gogoResponse: gogoResponse),
      ),
    );
  }
}
