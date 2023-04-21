import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/pages/AnimeScreens/AnimeDetailsScreen.dart';

import '../Skeletons/ImagesSliderSkeleton.dart';

class ContinueWatchingAnime extends StatefulWidget {
  const ContinueWatchingAnime({super.key});

  @override
  State<ContinueWatchingAnime> createState() => _ContinueWatchingAnimeState();
}

class _ContinueWatchingAnimeState extends State<ContinueWatchingAnime> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future removeAnime(index, List animeArr) async {
    final newContinueWatching = animeArr;
    newContinueWatching.removeAt(index);
    newContinueWatching.reversed.toList();
    _database
        .child("users/${_auth.currentUser!.uid}/continueWatching/animes")
        .set({'animes_arr': newContinueWatching});
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
              'users/${_auth.currentUser!.uid}/continueWatching/animes/animes_arr')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List animeArr = (snapshot.data!.snapshot.value ?? []) as List;
          List reverseAnimeArr = animeArr.reversed.toList();
          return reverseAnimeArr.isNotEmpty
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
                        height: 250,
                        margin: const EdgeInsets.only(top: 10, left: 5),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: reverseAnimeArr.length,
                          itemBuilder: (context, index) {
                            final item = reverseAnimeArr[index];
                            String inputString =
                                item['StreamingLink'].toString();
                            // Define a regular expression pattern to match the "episodeId" value
                            RegExp regExp = RegExp(r'episodeId=([^&]+)');
                            // Extract the "episodeId" from the input string
                            String episodeId =
                                regExp.firstMatch(inputString)?.group(1) ?? '';

                            RegExp regExpanimeLink =
                                RegExp(r'animeName=([^&]+)');
                            String animeName = regExpanimeLink
                                    .firstMatch(inputString)
                                    ?.group(1) ??
                                "";
                            episodeId = episodeId.split("-").last;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AnimeDetailsScreen(
                                                animeImageUrl:
                                                    item['anilistPoster']
                                                        ['large'],
                                                animeLink:
                                                    "/category/$animeName",
                                                animeName: item['title']
                                                        ['romaji'] ??
                                                    item['title']['english'] ??
                                                    item['title']
                                                        ['userPreferred'])));
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
                                            "${item['anilistPoster']['large']}",
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
                                                  removeAnime(
                                                      index, reverseAnimeArr);
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
                                        " ${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred'] ?? "NA"}",
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
                                        "Episode: $episodeId",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                                255, 224, 224, 224)),
                                      ),
                                    ),
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
