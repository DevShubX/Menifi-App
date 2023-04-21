import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Skeletons/CarouselSlideSkeleton.dart';
import 'package:menifi/pages/MovieScreens/MovieSearchSScreen.dart';
import 'package:menifi/pages/TVShowScreens/TVShowsSearchScreen.dart';

import '../constants.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({super.key});

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  int pageNumber = 1;
  late Map data;
  List trendingMovies = [];
  bool isLoading = true;
  Future getMovies() async {
    http.Response response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/trending/all/day?api_key=$key&language=en-US&page=$pageNumber"));

    data = json.decode(response.body);
    setState(() {
      trendingMovies = data['results'];
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
    return isLoading
        ? CarouselSlideSkeleton()
        : Container(
            margin: EdgeInsets.only(top: 60),
            child: CarouselSlider.builder(
                options: CarouselOptions(
                  viewportFraction: 1,
                  height: 300,
                  autoPlay: true,
                  enableInfiniteScroll: true,
                  enlargeFactor: 0.5,
                  enlargeCenterPage: true,
                ),
                itemCount: trendingMovies.length,
                itemBuilder: (context, index, realIndex) => Container(
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              foregroundDecoration: const BoxDecoration(
                                // borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(120, 0, 0, 0),
                                    Color.fromARGB(50, 0, 0, 0),
                                    Color.fromARGB(50, 0, 0, 0),
                                    Color.fromARGB(120, 0, 0, 0)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [0, 0.8, 1, 1],
                                ),
                              ),
                              child: Image.network(
                                fit: BoxFit.cover,
                                "https://image.tmdb.org/t/p/w780/${trendingMovies[index]['backdrop_path']}",
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                      fit: BoxFit.cover,
                                      'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(
                                            Color.fromARGB(255, 255, 17, 0)),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            Positioned(
                                top: 15,
                                left: 20,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${trendingMovies[index]['media_type']}" ==
                                                'tv'
                                            ? "${trendingMovies[index]['name']}"
                                            : "${trendingMovies[index]['title']}",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 20,
                                            color:
                                                Color.fromARGB(255, 255, 0, 0)),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.slideshow,
                                              color: Color.fromARGB(
                                                  255, 255, 17, 0),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                '${trendingMovies[index]['media_type']}'
                                                    .toUpperCase(),
                                                // ignore: prefer_const_constructors
                                                style: TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          children: [
                                            // ignore: prefer_const_constructors
                                            Icon(
                                              Icons.schedule,
                                              color: const Color.fromARGB(
                                                  255, 255, 17, 0),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                '${trendingMovies[index]['media_type']}' ==
                                                        'tv'
                                                    ? '${trendingMovies[index]['first_air_date']}'
                                                    : '${trendingMovies[index]['release_date']}',
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          '${trendingMovies[index]['overview']}',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          // ignore: prefer_const_constructors
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Gilroy-Medium',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // ignore: prefer_const_constructors
                                            Icon(
                                              Icons.star,
                                              color: const Color.fromARGB(
                                                  255, 255, 17, 0),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                '${trendingMovies[index]['vote_average']}'
                                                            .length >=
                                                        3
                                                    ? '${trendingMovies[index]['vote_average']}'
                                                        .substring(0, 3)
                                                    : '${trendingMovies[index]['vote_average']}',
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 15),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => trendingMovies[
                                                                        index][
                                                                    'media_type'] ==
                                                                'tv'
                                                            ? TVShowsSearchScreen(
                                                                tvShowName:
                                                                    trendingMovies[
                                                                            index]
                                                                        [
                                                                        'name'])
                                                            : MovieSearchScreen(
                                                                movieName:
                                                                    trendingMovies[
                                                                            index]
                                                                        [
                                                                        'title'],
                                                              )));
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 224, 28, 13),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: Row(children: [
                                                  const Icon(Icons
                                                      .play_circle_fill_rounded),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Text('Play',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Gilroy-Bold')),
                                                  )
                                                ]),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  border: Border.all(
                                                      color: Colors.white)),
                                              child: Row(children: [
                                                const Icon(Icons.add),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  child: const Text(
                                                    'My List',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Gilroy-Bold'),
                                                  ),
                                                )
                                              ]),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                    )),
          );
  }
}
