import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/pages/AnimeScreens/PopularAnimeScreen.dart';
import 'package:menifi/pages/AnimeScreens/TrendingAnimeScreen.dart';

import '../../pages/AnimeScreens/AnimeSearchScreen.dart';
import '../Skeletons/ImagesSliderSkeleton.dart';

class AnimeTrendingSlider extends StatefulWidget {
  const AnimeTrendingSlider({super.key});

  @override
  State<AnimeTrendingSlider> createState() => _AnimeTrendingSliderState();
}

class _AnimeTrendingSliderState extends State<AnimeTrendingSlider> {
  int pageNumber = 1;
  int count = 30;
  late Map data;
  List TrendingAnime = [];
  bool isLoading = true;
  Future getTrendingAnime() async {
    http.Response response = await http.get(Uri.parse(
        "https://redux-api-wine.vercel.app/api/trending?page=${pageNumber}&count=${count}"));

    data = json.decode(response.body);
    setState(() {
      TrendingAnime = data['data']['Page']['media'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getTrendingAnime();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        /// Text Portion Container
        Container(
          margin: EdgeInsets.only(top: 30, left: 15, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Trending Now",
                style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrendingAnimeScreen()));
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
        //// Photos Slider Container with each image of 120x185
        isLoading
            ? ImagesSliderSkeleton()
            : Container(
                /// This the main height of the full slider container , if this height is not given then it will
                /// cause render issue .
                height: 250,
                margin: const EdgeInsets.only(top: 15, left: 5),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        TrendingAnime.isNotEmpty ? TrendingAnime.length : 0,
                    itemBuilder: (BuildContext context, index) {
                      final item = TrendingAnime[index];

                      /// This container is for the images and text
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
                                      "${TrendingAnime[index]['coverImage']['large']}",
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
                                            color: const Color.fromARGB(85, 0, 0, 0),
                                            child:const  Center(
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
                                            "${TrendingAnime[index]['averageScore'] ?? "NA"}",
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
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  "${TrendingAnime[index]['title']['romaji'] ?? TrendingAnime[index]['title']['english'] ?? TrendingAnime[index]['title']['userPreferred']}",
                                  style: TextStyle(
                                    fontFamily: 'Gilroy-Medium',
                                    fontSize: 13,
                                    color: TrendingAnime[index]['coverImage']
                                                ['color'] !=
                                            null
                                        ? Color(int.parse(TrendingAnime[index]
                                                ['coverImage']['color']
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
      ]),
    );
  }
}
