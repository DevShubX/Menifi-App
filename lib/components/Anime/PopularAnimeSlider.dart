import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';
import 'package:menifi/pages/AnimeScreens/PopularAnimeScreen.dart';
import 'package:menifi/pages/MovieScreens/PopularMoviesScreen.dart';

import '../../pages/AnimeScreens/AnimeSearchScreen.dart';

class PopularAnimeSlider extends StatefulWidget {
  const PopularAnimeSlider({super.key});

  @override
  State<PopularAnimeSlider> createState() => _PopularAnimeSliderState();
}

class _PopularAnimeSliderState extends State<PopularAnimeSlider> {
  int pageNumber = 1;
  late Map data;
  List? Anime = [];
  bool isLoading = true;
  int count = 30;
  Future getAnime() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/popular?page=${pageNumber}&count=${count}'));

    data = json.decode(response.body);

    setState(() {
      Anime = data['data']['Page']['media'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getAnime();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          /// Text Portion
          Container(
            margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Time Popular Anime",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PopularAnimeScreen()));
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        color: Color.fromARGB(255, 255, 17, 0),
                        fontSize: 15),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? const ImagesSliderSkeleton()
              : Container(
                  height: 250,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: Anime!.length,
                      itemBuilder: (BuildContext context, index) {
                        final item = Anime![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AnimeSearchScreen(
                                        animeName:
                                            "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}")));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width:
                                120, //This is container width which include text and image both
                            child: Column(
                              children: [
                                /// This cliprect is for images and rating in a stack
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Stack(
                                    fit: StackFit.passthrough,
                                    children: [
                                      Image.network(
                                        "${item['coverImage']['extraLarge']}",
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
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          else {
                                            return Container(
                                              width: 120,
                                              height: 185,
                                              color: const Color.fromARGB(
                                                  85, 0, 0, 0),
                                              child: const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive(),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    255, 255, 17, 0)),
                                            child: Text(
                                              "${item['averageScore'] ?? "NA"}",
                                              style: const TextStyle(
                                                  fontFamily: 'Gilroy-Bold',
                                                  fontSize: 11,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}",
                                    style: TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 13,
                                      color: item['coverImage']['color'] != null
                                          ? Color(int.parse(item['coverImage']
                                                  ['color']
                                              .toString()
                                              .replaceAll("#", "0XFF")))
                                          : Colors.white,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}
