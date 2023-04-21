import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/pages/TVShowScreens/OnTheAirTvShowsScreen.dart';
import '../../pages/TVShowScreens/TVShowsSearchScreen.dart';
import '../Skeletons/ImagesSliderSkeleton.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TvOnTheAirSlider extends StatefulWidget {
  const TvOnTheAirSlider({super.key});

  @override
  State<TvOnTheAirSlider> createState() => _TvOnTheAirSliderState();
}

class _TvOnTheAirSliderState extends State<TvOnTheAirSlider> {
  int pageNumber = 1;
  late Map data;
  List? TVShows = [];
  bool isLoading = true;

  Future getTVShows() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/on_the_air?api_key=$key&language=en-US&page=$pageNumber'));

    data = json.decode(response.body);

    setState(() {
      TVShows = data['results'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getTVShows();
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
                  "On The Air",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnTheAirTvShowsScreen()));
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
                      itemCount: TVShows!.length,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TVShowsSearchScreen(
                                          tvShowName: TVShows![index]['name'] ??
                                              TVShows![index]['original_name'],
                                        )));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: 120,
                            height: 185,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Image.network(
                                    'https://image.tmdb.org/t/p/w185/${TVShows![index]['poster_path']}',
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
                                          " ${double.parse(TVShows![index]['vote_average'].toStringAsFixed(1))}",
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
