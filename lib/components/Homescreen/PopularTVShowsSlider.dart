import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/TVShowScreens/PopularTvShowsScreen.dart';
import 'package:menifi/pages/TVShowScreens/TVShowsSearchScreen.dart';
import 'dart:convert';
import 'dart:async';

import '../Skeletons/ImagesSliderSkeleton.dart';
import '../constants.dart';

class PopularTVShowsSlider extends StatefulWidget {
  const PopularTVShowsSlider({super.key});

  @override
  State<PopularTVShowsSlider> createState() => _PopularTVShowsSliderState();
}

class _PopularTVShowsSliderState extends State<PopularTVShowsSlider> {
  late Map data;
  List PopularTVShows = [];
  bool isLoading = true;

  Future getPopularTVShows() async {
    http.Response response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/tv/popular?api_key=${key}&language=en-US&page=1"));

    data = json.decode(response.body);
    setState(() {
      PopularTVShows = data['results'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getPopularTVShows();
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
          /// Text Portion Container
          Container(
            margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular TV Shows",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PopularTvShowsScreen()));
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
              ? const ImagesSliderSkeleton()
              : Container(
                  height: 185,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          PopularTVShows.isNotEmpty ? PopularTVShows.length : 0,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TVShowsSearchScreen(
                                          tvShowName: PopularTVShows[index]
                                              ['name'],
                                        )));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 120,
                            height: 185,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Image.network(
                                    'https://image.tmdb.org/t/p/w185/${PopularTVShows[index]['poster_path']}',
                                    fit: BoxFit.cover,
                                    height: 185,
                                    width: 120,
                                    errorBuilder: (context, error, stackTrace) {
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
                                          color: Color.fromARGB(85, 0, 0, 0),
                                          child: Center(
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
                                            color: Color.fromARGB(
                                                255, 255, 17, 0)),
                                        child: Text(
                                          " ${PopularTVShows[index]['vote_average'] ?? "NA"}"
                                          //         .length >=
                                          //     3
                                          // ? "${PopularTVShows[index]['vote_average']}"
                                          //     .substring(0, 3)
                                          // : "${PopularTVShows[index]['vote_average']}"
                                          //     .substring(0, 1),
                                          ,
                                          style: const TextStyle(
                                              fontFamily: 'Gilroy-Bold',
                                              fontSize: 11,
                                              color: Colors.white),
                                        ),
                                      ))
                                ],
                              ),
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
