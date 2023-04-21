import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';

import '../../pages/MovieScreens/MovieDetailScreen.dart';

class ContinueWatchingMoviesSlider extends StatefulWidget {
  const ContinueWatchingMoviesSlider({super.key});

  @override
  State<ContinueWatchingMoviesSlider> createState() =>
      _ContinueWatchingMoviesSliderState();
}

class _ContinueWatchingMoviesSliderState
    extends State<ContinueWatchingMoviesSlider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future removeMovie(index, List movieArr) async {
    final newContinueWatching = movieArr;
    newContinueWatching.removeAt(index);
    newContinueWatching.reversed.toList();
    _database
        .child("users/${_auth.currentUser!.uid}/continueWatching/movies")
        .set({'movies_arr': newContinueWatching});
  }

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
    return StreamBuilder(
      stream: _database
          .child(
              'users/${_auth.currentUser!.uid}/continueWatching/movies/movies_arr')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List moviearr = (snapshot.data!.snapshot.value ?? []) as List;
          List reverseMovieArr = moviearr.reversed.toList();
          return moviearr.isNotEmpty
              ? Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 30, left: 15, right: 20),
                        child: const Text(
                          "Continue Watching",
                          style: TextStyle(
                              fontFamily: 'Gilroy-Bold', fontSize: 19),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 230,
                        margin: const EdgeInsets.only(top: 10, left: 5),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: moviearr.length,
                          itemBuilder: (context, index) {
                            final item = reverseMovieArr[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MovieDetailScreen(
                                                movieName: "${item['title']}",
                                                imageUrl:
                                                    "${item['filmPoster']}",
                                                movieId: "${item['id']}")));
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: 120,
                                height: 220,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            "${item['filmPoster']}",
                                            height: 185,
                                            width: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.network(
                                                  width: 120,
                                                  height: 185,
                                                  fit: BoxFit.cover,
                                                  'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Container(
                                                  width: 120,
                                                  height: 185,
                                                  color: const Color.fromARGB(
                                                      85, 0, 0, 0),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Positioned(
                                              top: 5,
                                              right: 5,
                                              child: GestureDetector(
                                                onTap: () {
                                                  removeMovie(
                                                      index, reverseMovieArr);
                                                },
                                                child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.white),
                                                    child: const Icon(
                                                      Icons.cancel_rounded,
                                                      size: 27,
                                                      color: Colors.red,
                                                    )),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        " ${item['title'] ?? "NA"}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 13,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]))
              : Container();
        } else {
          return ImagesSliderSkeleton();
        }
      },
    );
  }
}
