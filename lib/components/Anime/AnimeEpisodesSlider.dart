import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Anime/GogoAnimeDetails.dart';
import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';
import 'package:menifi/components/VideoPlayers/AnimeVideoPlayer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class AnimeEpisodesSlider extends StatefulWidget {
  const AnimeEpisodesSlider(
      {super.key,
      required this.anilistListId,
      required this.animeName,
      this.gogoResponse,
      this.anilistResponse,
      this.animeLink});
  final animeName;
  final anilistListId;
  final gogoResponse;
  final anilistResponse;
  final animeLink;
  @override
  State<AnimeEpisodesSlider> createState() => _AnimeEpisodesSliderState();
}

class _AnimeEpisodesSliderState extends State<AnimeEpisodesSlider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Map data = {};
  bool isLoading = true;
  late Map sourcesData;
  List sources = [];
  List sources_bk = [];

  Future getAnimeEpisodes(String id) async {
    http.Response response = await http
        .get(Uri.parse('https://api.consumet.org/meta/anilist/info/$id'));
    if (!mounted) return;
    setState(() {
      data = json.decode(response.body);
      isLoading = false;
    });
  }

  Future getAnimeStreamingLink(String animeStreamId) async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/getlinks?link=/$animeStreamId'));

    sourcesData = json.decode(response.body)[0];
    setState(() {
      sources = sourcesData['sources']['sources'];
      sources_bk = sourcesData['sources']['sources_bk'];
    });
  }

  Future updateContinueWatching(userId, Map animeDetails, streamingLink) async {
    DatabaseReference dbref = FirebaseDatabase.instance
        .ref()
        .child('users/$userId/continueWatching/animes');
    List<dynamic> arr = [];

    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/continueWatching/animes/animes_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List cntWatching = snapshot.value as List;
          for (var snap in cntWatching) {
            if (snap['id'] != animeDetails['id']) {
              arr.add(snap);
            }
          }
          arr.add({
            ...animeDetails,
            'StreamingLink': streamingLink,
          });
          await dbref.set({'animes_arr': arr});
        } else {
          arr.add({
            ...animeDetails,
            'StreamingLink': streamingLink,
          });
          // print('No data available');
          await dbref.set({'animes_arr': arr});
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
            if (snap['id'] != animeDetails['id']) {
              arr2.add(snap);
            }
          }
          arr2.add({
            ...animeDetails,
            'StreamingLink': streamingLink,
          });
          await dbref2.set({'recently_watched_arr': arr2});
        } else {
          arr2.add({
            ...animeDetails,
            'StreamingLink': streamingLink,
          });
          await dbref2.set({'recently_watched_arr': arr2});
        }
      });

      // ignore: empty_catches
    } catch (error) {}
  }

  @override
  void initState() {
    if (widget.anilistListId != null) {
      getAnimeEpisodes(widget.anilistListId);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const EpisodesShimmer()
        : (data['episodes'] == null || data['episodes'].length <= 0)
            ? (widget.gogoResponse['episodes'] != null &&
                    widget.gogoResponse['episodes'].isNotEmpty)
                ? Container(
                    height: widget.gogoResponse['episodes'].length > 70
                        ? 570
                        : null,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      physics: widget.gogoResponse['episodes'].length > 70
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.gogoResponse['episodes'].length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // print(widget.animeLink
                            //     .toString()
                            //     .replaceAll("/category/", ""));
                            // print(
                            //     "/animes/watch&episodeId=${widget.gogoResponse['episodes'][index].toString().replaceAll("/", "")}&animeName=${widget.animeLink.toString().replaceAll("/category/", "")}&id=${widget.anilistListId}");
                            updateContinueWatching(
                                _auth.currentUser!.uid,
                                widget.anilistResponse,
                                "/animes/watch&episodeId=${widget.gogoResponse['episodes'][index].toString().replaceAll("/", "")}&animeName=${widget.animeLink.toString().replaceAll("/category/", "")}&id=${widget.anilistListId}");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return FutureBuilder(
                                future: getAnimeStreamingLink(widget
                                    .gogoResponse['episodes'][index]
                                    .toString()
                                    .replaceAll("/", "")),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return AnimeVideoPlayer(
                                      sources: sources,
                                    );
                                  } else {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                },
                              );
                            }));
                          },
                          child: Container(
                            height: 110,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  height: 110,
                                  width: 130,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  alignment: Alignment.topLeft,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          '${widget.gogoResponse['image']}',
                                          height: 110,
                                          width: 130,
                                          opacity:
                                              const AlwaysStoppedAnimation(0.9),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.network(
                                                width: 130,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Container(
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
                                        const Positioned.fill(
                                            child: Icon(
                                          CupertinoIcons.play_circle,
                                          size: 40,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                        )),
                                        Positioned(
                                            bottom: 5,
                                            right: 5,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 2),
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      190, 0, 0, 0)),
                                              child: Text(
                                                '${data['duration'] ?? "NA"}m',
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 13),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                          flex: 0,
                                          child: Text(
                                            '${widget.gogoResponse['title'] ?? "NA"}',
                                            style: const TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize: 12,
                                                color: Colors.grey),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                          flex: 0,
                                          child: Text(
                                            "Episode - ${index + 1}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontFamily: 'Gilroy-Medium'),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ))
                : Container(
                    margin: const EdgeInsets.only(left: 15, top: 20),
                    child: const Text(
                      "No Episodes Available\n\n If anime is released then try to refresh",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          color: Colors.grey,
                          fontSize: 19),
                    ),
                  )
            : Column(
                children: [
                  Container(
                    height: data['episodes'].length > 70 ? 570 : null,
                    margin: const EdgeInsets.only(top: 10, left: 5),
                    child: ListView.builder(
                        physics: data['episodes'].length > 70
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(right: 5),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: data['episodes'].length,
                        itemBuilder: (BuildContext context, index) {
                          final date = data['episodes'][index]['airDate'];
                          var formated = "NA";
                          if (date != null) {
                            DateTime dateTime = DateTime.parse(date);
                            formated =
                                DateFormat('EEE, MMMM d, y').format(dateTime);
                          }

                          return GestureDetector(
                            onTap: () {
                              updateContinueWatching(
                                  _auth.currentUser!.uid,
                                  widget.anilistResponse,
                                  "/animes/watch&episodeId=${widget.gogoResponse['episodes'][index].toString().replaceAll("/", "")}&animeName=${widget.animeLink.toString().replaceAll("/category/", "")}&id=${widget.anilistListId}");
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return FutureBuilder(
                                    future: getAnimeStreamingLink(
                                        data['episodes'][index]['id']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return AnimeVideoPlayer(
                                          sources: sources,
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
                              height: 110,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    height: 110,
                                    width: 130,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    alignment: Alignment.topLeft,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            data['episodes'][index]['image']
                                                    .toString()
                                                    .contains('anilist')
                                                ? "${data['episodes'][index]['image']}"
                                                : 'https://images.weserv.nl/?url=${data['episodes'][index]['image']}',
                                            height: 110,
                                            width: 130,
                                            opacity:
                                                const AlwaysStoppedAnimation(
                                                    0.9),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.network(
                                                  width: 130,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                  'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Container(
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
                                          const Positioned.fill(
                                              child: Icon(
                                            CupertinoIcons.play_circle,
                                            size: 40,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )),
                                          Positioned(
                                              bottom: 5,
                                              right: 5,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3,
                                                        vertical: 2),
                                                decoration: const BoxDecoration(
                                                    color: Color.fromARGB(
                                                        190, 0, 0, 0)),
                                                child: Text(
                                                  '${data['duration'] ?? "NA"}m',
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Gilroy-Medium',
                                                      fontSize: 13),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Text(
                                              '${widget.animeName}',
                                              style: const TextStyle(
                                                  fontFamily: 'Gilroy-Medium',
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Text(
                                              "Ep ${data['episodes'][index]['number'] ?? "NA"} - ${data['episodes'][index]['title'] ?? "NA"}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontFamily: 'Gilroy-Medium'),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          formated,
                                          style: const TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 13,
                                              color: Colors.grey),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              );
  }
}

class EpisodesShimmer extends StatelessWidget {
  const EpisodesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            int timer = 1000;
            return Container(
              height: 90,
              child: Row(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(right: 10, left: 20, bottom: 20),
                    child: Shimmer.fromColors(
                      baseColor: const Color.fromARGB(85, 0, 0, 0),
                      highlightColor: const Color.fromARGB(255, 124, 122, 122),
                      child: Container(
                        height: 90,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: const Color.fromARGB(85, 0, 0, 0),
                        highlightColor:
                            const Color.fromARGB(255, 124, 122, 122),
                        child: Container(
                          height: 20,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Shimmer.fromColors(
                        baseColor: const Color.fromARGB(85, 0, 0, 0),
                        highlightColor:
                            const Color.fromARGB(255, 124, 122, 122),
                        child: Container(
                          height: 20,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
