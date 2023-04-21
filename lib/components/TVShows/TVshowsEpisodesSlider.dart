import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';
import 'package:shimmer/shimmer.dart';

import '../VideoPlayers/MovieVideoPlayer.dart';

class TVShowsEpisodeSlider extends StatefulWidget {
  const TVShowsEpisodeSlider(
      {super.key,
      this.tvshowDetails,
      required this.tvshowid,
      required this.tvshowName,
      required this.tvshowFullId});
  final String
      tvshowid; // this id is a numeric id that is need for the seasons retrival;
  final tvshowName;
  final tvshowFullId;
  final tvshowDetails;
  @override
  State<TVShowsEpisodeSlider> createState() => _TVShowsEpisodeSliderState();
}

class _TVShowsEpisodeSliderState extends State<TVShowsEpisodeSlider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String TVSeasonId = "";
  late List TVShowSeasons = [];
  bool isLoading = true;
  late List TvEpisodes = [];
  List sources = [];
  List subtitles = [];
  var downloadLink;
  late Map sourcedata;
  Future getTVSeasons(String tvid) async {
    http.Response response = await http
        .get(Uri.parse('https://menifi-api.vercel.app/api/tv/seasons/${tvid}'));

    setState(() {
      TVShowSeasons = json.decode(response.body);
      TVSeasonId = TVShowSeasons.first['seasonId'];
    });
    if (TVSeasonId != "") {
      getTVShowEpisodes(TVSeasonId);
    }
  }

  Future getTVShowEpisodes(String seasonID) async {
    http.Response response = await http.get(
        Uri.parse('https://menifi-api.vercel.app/api/tv/episodes/${seasonID}'));

    setState(() {
      TvEpisodes = json.decode(response.body);
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

  Future updateContinueWatching(
      userId, Map tvshowDetails, tvString, streamingLink) async {
    DatabaseReference dbref = FirebaseDatabase.instance
        .ref()
        .child('users/$userId/continueWatching/tvshows');
    List<dynamic> arr = [];

    try {
      await FirebaseDatabase.instance
          .ref()
          .child("users/$userId/continueWatching/tvshows/tvshows_arr")
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          List cntWatching = snapshot.value as List;
          for (var snap in cntWatching) {
            if (snap['movieId'] != tvshowDetails['movieId']) {
              arr.add(snap);
            }
          }
          arr.add({
            ...tvshowDetails,
            'TvDetailsPage': tvString,
            'TvStreamingLink': streamingLink,
          });
          await dbref.set({'tvshows_arr': arr});
        } else {
          arr.add({
            ...tvshowDetails,
            'TvDetailsPage': tvString,
            'TvStreamingLink': streamingLink,
          });
          // print('No data available');
          await dbref.set({'tvshows_arr': arr});
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
            if (snap['movieId'] != tvshowDetails['movieId']) {
              arr2.add(snap);
            }
          }
          arr2.add({
            ...tvshowDetails,
            'TvDetailsPage': tvString,
            'TvStreamingLink': streamingLink,
          });
          await dbref2.set({'recently_watched_arr': arr2});
        } else {
          arr2.add({
            ...tvshowDetails,
            'TvDetailsPage': tvString,
            'TvStreamingLink': streamingLink,
          });
          await dbref2.set({'recently_watched_arr': arr2});
        }
      });

      // ignore: empty_catches
    } catch (error) {}
  }

  @override
  void initState() {
    if (widget.tvshowid != null) {
      getTVSeasons(widget.tvshowid);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 15, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Episodes",
                style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 20),
              ),
              DropdownButton(
                iconSize: 22,
                borderRadius: BorderRadius.circular(15),
                underline: Container(),
                style: const TextStyle(fontSize: 15),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.red,
                ),
                value: TVSeasonId,
                items: TVShowSeasons.map((e) {
                  return DropdownMenuItem(
                      value: e['seasonId'], child: Text("${e['seasonName']}"));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    TVSeasonId = value.toString();
                  });
                  getTVShowEpisodes(TVSeasonId);
                },
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 5),
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: TvEpisodes.isNotEmpty ? TvEpisodes.length : 0,
              itemBuilder: (BuildContext context, index) {
                return GestureDetector(
                  onTap: () {
                    updateContinueWatching(
                        _auth.currentUser!.uid,
                        widget.tvshowDetails,
                        "tv/${widget.tvshowDetails['id']}",
                        "/tvshows/watch&episodeId=${TvEpisodes[index]['episodeId']}&mediaId=tv+${widget.tvshowDetails['id']}&episodeName=${TvEpisodes[index]['episodeName']}");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return FutureBuilder(
                          future: getMovieLink(
                              '${TvEpisodes[index]['episodeId']}',
                              '${widget.tvshowFullId}'),
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
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                          });
                    }));
                  },
                  child: Container(
                    height: 90,
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 120,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          alignment: Alignment.topLeft,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(
                              children: [
                                Image.network(
                                  '${TvEpisodes[index]['coverImage'] ?? ""}',
                                  height: 90,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        width: 120,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Container(
                                        color:
                                            const Color.fromARGB(85, 0, 0, 0),
                                        child: const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Positioned.fill(
                                    child: Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 40,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                )),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  flex: 0,
                                  child: Text(
                                    '${widget.tvshowName}',
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
                                    '${TvEpisodes[index]['episodeName'] ?? "Episode:${index + 1}"}',
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
    return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          int timer = 1000;
          return Container(
            height: 90,
            child: Row(
              children: [
                Container(
                  child: Shimmer.fromColors(
                    baseColor: Color.fromARGB(85, 0, 0, 0),
                    highlightColor: Color.fromARGB(255, 124, 122, 122),
                    child: Container(
                      height: 90,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ),
                Container(
                  child: Shimmer.fromColors(
                    child: Container(
                      height: 10,
                    ),
                    baseColor: Color.fromARGB(85, 0, 0, 0),
                    highlightColor: Color.fromARGB(255, 124, 122, 122),
                  ),
                )
              ],
            ),
          );
        });
  }
}
