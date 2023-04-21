import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Skeletons/CarouselSlideSkeleton.dart';
import 'package:menifi/components/constants.dart';
import 'package:menifi/pages/MovieScreens/MovieSearchSScreen.dart';
import 'package:intl/intl.dart';

class MoviesCarousel extends StatefulWidget {
  const MoviesCarousel({super.key});

  @override
  State<MoviesCarousel> createState() => _MoviesCarouselState();
}

class _MoviesCarouselState extends State<MoviesCarousel> {
  int pageNumber = 1;
  late Map data;
  List Movies = [];
  bool isLoading = true;

  Future getMovies() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$key&language=en-US&page=$pageNumber'));

    data = json.decode(response.body);

    setState(() {
      Movies = data['results'];
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
                  enlargeCenterPage: true,
                  enlargeFactor: 0.5,
                ),
                itemCount: Movies.length,
                itemBuilder: (context, index, realIndex) {
                  final item = Movies[index];
                  final date = DateFormat.yMMMd()
                      .format(DateTime.parse(item['release_date']));
                  return Container(
                    child: ClipRRect(
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
                              "https://image.tmdb.org/t/p/w780/${Movies[index]['backdrop_path']}",
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

                          /// Image container end
                          Positioned(
                              top: 15,
                              left: 20,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      ///Heading Text
                                      "${Movies[index]['title']}",
                                      style: const TextStyle(
                                          fontFamily: 'Gilroy-Bold',
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 255, 0, 0)),
                                    ),
                                    Container(
                                      /// Media Type text in this case it is MOVIE
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.slideshow,
                                            color:
                                                Color.fromARGB(255, 255, 17, 0),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              'MOVIE',
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
                                      //// Release Date Text
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          // ignore: prefer_const_constructors
                                          Icon(
                                            Icons.schedule,
                                            color:
                                                Color.fromARGB(255, 255, 17, 0),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              '${date}',
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
                                        '${Movies[index]['overview']}',
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
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // ignore: prefer_const_constructors
                                          Icon(
                                            Icons.star,
                                            color:
                                                Color.fromARGB(255, 255, 17, 0),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              '${double.parse(Movies[index]['vote_average'].toStringAsFixed(1))}',
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
                                              /// Play Command
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MovieSearchScreen(
                                                            movieName:
                                                                Movies[index]
                                                                    ['title'],
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
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  child: const Text('Play',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Gilroy-Bold')),
                                                )
                                              ]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              /// Addlist to My List Logic
                                            },
                                            child: Container(
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
                  );
                }),
          );
  }
}
