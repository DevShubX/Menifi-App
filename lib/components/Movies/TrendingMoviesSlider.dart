import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/MovieScreens/MovieSearchSScreen.dart';
import 'package:menifi/pages/MovieScreens/TrendingMoviesScreen.dart';
import 'dart:convert';
import 'dart:async';

import '../Skeletons/ImagesSliderSkeleton.dart';
import '../constants.dart';

class TrendingMoviesSlider extends StatefulWidget {
  const TrendingMoviesSlider({super.key});

  @override
  State<TrendingMoviesSlider> createState() => _TrendingMoviesSliderState();
}

class _TrendingMoviesSliderState extends State<TrendingMoviesSlider> {
  int pageNumber = 1;
  late Map data;
  List TrendingMovies = [];
  bool isLoading = true;

  Future getMovies() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/trending/movie/day?api_key=$key'));

    data = json.decode(response.body);

    setState(() {
      TrendingMovies = data['results'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMovies();
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
            margin: EdgeInsets.only(top: 30, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trending Today",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TrendingMoviesScreen()));
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
                  height: 185,
                  margin: EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          TrendingMovies.isNotEmpty ? TrendingMovies.length : 0,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MovieSearchScreen(
                                          movieName: TrendingMovies[index]
                                                  ['title'] ??
                                              TrendingMovies[index]
                                                  ['original_title'],
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
                                    'https://image.tmdb.org/t/p/w185/${TrendingMovies[index]['poster_path']}',
                                    height: 185,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          width: 120,
                                          height: 185,
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
                                          "${double.parse(TrendingMovies[index]['vote_average'].toStringAsFixed(1))}",
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
