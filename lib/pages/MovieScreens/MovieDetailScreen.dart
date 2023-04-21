import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/components/Homescreen/PopularMoviesSlider.dart';
import 'package:menifi/components/Movies/UpComingMoviesSlider.dart';
import 'package:menifi/components/Skeletons/CarouselSlideSkeleton.dart';
import 'package:menifi/components/VideoPlayers/MovieVideoPlayer.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen(
      {super.key, required this.movieId, this.movieName, this.imageUrl});
  final String movieId;
  final movieName;
  final imageUrl;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Map data = {};
  bool isLoading = true;
  List sources = [];
  List subtitles = [];
  var downloadLink;
  late Map sourcedata;
  Future getMovieInfo(String movieId) async {
    http.Response response = await http.get(Uri.parse(
        'https://menifi-api.vercel.app/api/info/flixhq/movie/${movieId}'));

    setState(() {
      data = json.decode(response.body);
      isLoading = false;
    });
  }

  Future getMovieLink(episodeId, mediaId) async {
    http.Response res = await http.get(Uri.parse(
        'https://menifi-api.vercel.app/api/links/sources/?episodeId=${episodeId}&mediaId=${mediaId}'));
    sourcedata = json.decode(res.body);

    setState(() {
      sources = sourcedata['sources']['sources'];
      subtitles = sourcedata['sources']['subtitles'];
      downloadLink = sourcedata['sources']['downloadLink'];
    });
  }

  // movieString is taken for the web port of the web site without this we can
  // cannot navigate in the website when we click on the photo.
  Future addMovieToFav(userId, Map movieDetails, movieString) async {
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
            if (snap['movieId'] != movieDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          await dbref.set({'fav_arr': arr});
        } else {
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          print('No data available');
          await dbref.set({'fav_arr': arr});
        }
      });
      popupToast("Added To Favourites");
    } catch (error) {
      print(error);
    }
  }

  Future addMovieToWishList(userId, Map movieDetails, movieString) async {
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
            if (snap['movieId'] != movieDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          await dbref.set({'wishlist_arr': arr});
        } else {
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          // print('No data available');
          await dbref.set({'wishlist_arr': arr});
        }
      });
      popupToast("Added To Wishlist");
    } catch (error) {
      // print(error);
    }
  }

  Future updateContinueWatching(userId, Map movieDetails, movieString) async {
    DatabaseReference dbref = FirebaseDatabase.instance
        .ref()
        .child('users/$userId/continueWatching/movies');
    List<dynamic> arr = [];

    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/continueWatching/movies/movies_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List cntWatching = snapshot.value as List;

          for (var snap in cntWatching) {
            if (snap['movieId'] != movieDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          await dbref.set({'movies_arr': arr});
        } else {
          arr.add({...movieDetails, 'movieStreamingLink': movieString});
          // print('No data available');
          await dbref.set({'movies_arr': arr});
        }
      });
    } catch (error) {
      // print(error);
    }

    DatabaseReference dbref2 =
        FirebaseDatabase.instance.ref().child('users/$userId/recentlyWatched/');
    List<dynamic> arr2 = [];
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/recentlyWatched/recently_watched_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List rcntWatched = snapshot.value as List;

          for (var snap in rcntWatched) {
            if (snap['movieId'] != movieDetails['movieId']) {
              arr2.add(snap);
            }
          }
          arr2.add({...movieDetails, 'movieStreamingLink': movieString});
          await dbref2.set({'recently_watched_arr': arr2});
        } else {
          arr2.add({...movieDetails, 'movieStreamingLink': movieString});
          // print('No data available');
          await dbref2.set({'recently_watched_arr': arr2});
        }
      });

      // ignore: empty_catches
    } catch (error) {}
  }

  @override
  void initState() {
    if (widget.movieId != null) {
      getMovieInfo(widget.movieId);
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
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
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
                          widget.imageUrl,
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
                      "${widget.movieName}",
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
                                    addMovieToWishList(
                                        _auth.currentUser!.uid,
                                        data,
                                        "/movies/watch&episodeId=${data['episodes'][0]['id']}&mediaId=movie+${data['id']}");
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
                                    addMovieToFav(_auth.currentUser!.uid, data,
                                        "/movies/watch&episodeId=${data['episodes'][0]['id']}&mediaId=movie+${data['id']}");
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
                            onTap: () {
                              /// This will update the continue watching and the recently watched movies.
                              updateContinueWatching(
                                  _auth.currentUser!.uid,
                                  data,
                                  "/movies/watch&episodeId=${data['episodes'][0]['id']}&mediaId=movie+${data['id']}");

                              /// Pushing the context to the videoplayer screen.
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return FutureBuilder(
                                    future: getMovieLink(
                                        '${data['episodes'][0]['id']}',
                                        '${data['movieId']}'),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return MovieVidePlayer(
                                          sources: sources,
                                          subtitles: subtitles,
                                          downloadLink: downloadLink,
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        );
                                      }
                                    });
                              }));
                            },
                            child: Container(
                              //// Watch now button
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                  left: 20, right: 20, top: 40),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 0, 0),
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
                                  maxLines: 13,
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
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data['genres']!.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    59, 175, 175, 175)),
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
                                                  color: Color.fromARGB(
                                                      255, 233, 233, 233),
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
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data['casts']!.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    59, 175, 175, 175)),
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
                          const UpComingMoviesSlider(),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CustomShimer extends StatelessWidget {
  const CustomShimer({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Shimmer.fromColors(
        baseColor: Color.fromARGB(85, 0, 0, 0),
        highlightColor: Color.fromARGB(255, 124, 122, 122),
        child: Container(
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
