import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../pages/TVShowScreens/TVShowDetailsScreen.dart';
import '../Skeletons/ImagesSliderSkeleton.dart';

class ContinueWatchingTvShowsSlider extends StatefulWidget {
  const ContinueWatchingTvShowsSlider({super.key});

  @override
  State<ContinueWatchingTvShowsSlider> createState() =>
      _ContinueWatchingTvShowsSliderState();
}

class _ContinueWatchingTvShowsSliderState
    extends State<ContinueWatchingTvShowsSlider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future removeMovie(index, List tvshowArr) async {
    final newContinueWatching = tvshowArr;
    newContinueWatching.removeAt(index);
    newContinueWatching.reversed.toList();
    _database
        .child("users/${_auth.currentUser!.uid}/continueWatching/tvshows")
        .set({'tvshows_arr': newContinueWatching});
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
              'users/${_auth.currentUser!.uid}/continueWatching/tvshows/tvshows_arr')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List tvshowarr = (snapshot.data!.snapshot.value ?? []) as List;
          List reverseTvShowArr = tvshowarr.reversed.toList();
          return reverseTvShowArr.isNotEmpty
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
                        height: 280,
                        margin: const EdgeInsets.only(top: 10, left: 5),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: reverseTvShowArr.length,
                          itemBuilder: (context, index) {
                            final item = reverseTvShowArr[index];
                            String inputString =
                                item['TvStreamingLink'].toString();
                            // Define a regular expression pattern to match the "episodeId" value
                            RegExp regExp = RegExp(r'episodeId=([^&]+)');
                            // Extract the "episodeId" from the input string
                            String episodeId =
                                regExp.firstMatch(inputString)?.group(1) ?? '';

                            List episodes = reverseTvShowArr[index]['episodes'];
                            var number, season, title;
                            episodes.forEach(
                              (element) {
                                if (element['id'] == episodeId) {
                                  number = element['number'];
                                  season = element['season'];
                                  title = element['title'];
                                }
                              },
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            TVShowDetailsScreen(
                                                tvshowImage: item['filmPoster'],
                                                tvshowName: item['title'],
                                                tvshowId: item['id'])));
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: 120,
                                height: 220,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      index, reverseTvShowArr);
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
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        "Season: ${season ?? "NA"}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 13,
                                            color: Color.fromARGB(
                                                255, 224, 224, 224)),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        "${title ?? "NA"}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                                255, 224, 224, 224)),
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
          return const ImagesSliderSkeleton();
        }
      },
    );
  }
}
