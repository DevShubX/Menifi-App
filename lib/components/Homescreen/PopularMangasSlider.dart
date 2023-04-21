import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/MangaScreens/MangaScreen.dart';
import 'package:menifi/pages/MangaScreens/MangaSearchScreen.dart';
import 'package:menifi/pages/MangaScreens/PopularMangaScreen.dart';
import 'dart:convert';
import 'dart:async';

import '../Skeletons/ImagesSliderSkeleton.dart';

class PopularMangasSlider extends StatefulWidget {
  const PopularMangasSlider({super.key});

  @override
  State<PopularMangasSlider> createState() => _PopularMangasSliderState();
}

class _PopularMangasSliderState extends State<PopularMangasSlider> {
  late Map data;
  List PopularMangas = [];
  bool isLoading = true;

  Future getPopularMangas() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/popular/manga?page=1&count=20'));

    data = json.decode(response.body);

    setState(() {
      PopularMangas = data['data']['Page']['media'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getPopularMangas();
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
                  "All Time Popular Mangas",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PopularMangaScreen()));
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
                  /// This the main height of the full slider container , if this height is not given then it will
                  /// cause render issue .
                  height: 230,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          PopularMangas.isNotEmpty ? PopularMangas.length : 0,
                      itemBuilder: (BuildContext context, index) {
                        /// This container is for the images and text
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MangaSearchScreen(
                                        mangaName: PopularMangas[index]['title']
                                                    ['romaji'] ==
                                                null
                                            ? PopularMangas[index]['title']
                                                ['romaji']
                                            : PopularMangas[index]['title']
                                                ['userPreferred'])));
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
                                        "${PopularMangas[index]['coverImage']['large']}",
                                        fit: BoxFit.cover,
                                        height: 185,
                                        width: 120,
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
                                              color:
                                                  Color.fromARGB(85, 0, 0, 0),
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
                                                color: const Color.fromARGB(
                                                    255, 255, 17, 0)),
                                            child: Text(
                                              PopularMangas[index]
                                                          ['averageScore'] ==
                                                      null
                                                  ? 'N/A'
                                                  : "${PopularMangas[index]['averageScore'] / 10}",
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
                                    "${PopularMangas[index]['title']['romaji'] == null ? PopularMangas[index]['title']['romaji'] : PopularMangas[index]['title']['userPreferred']}",
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 13),
                                    maxLines: 2,
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
