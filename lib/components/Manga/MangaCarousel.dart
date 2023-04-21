import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/components/Skeletons/CarouselSlideSkeleton.dart';
import 'package:menifi/pages/MangaScreens/MangaSearchScreen.dart';

class MangaCarousel extends StatefulWidget {
  const MangaCarousel({super.key});

  @override
  State<MangaCarousel> createState() => _MangaCarouselState();
}

class _MangaCarouselState extends State<MangaCarousel> {
  int pageNumber = 1;
  late Map data;
  List? Manga = [];
  bool isLoading = true;
  int count = 20;
  Future getManga() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/trending/manga?page=${pageNumber}&count=${count}'));

    data = json.decode(response.body);

    setState(() {
      Manga = data['data']['Page']['media'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getManga();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CarouselSlideSkeleton()
        : Container(
            margin: const EdgeInsets.only(top: 55),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                viewportFraction: 1,
                height: 300,
                autoPlay: true,
                enableInfiniteScroll: true,
                enlargeCenterPage: true,
                enlargeFactor: 0.5,
              ),
              itemCount: Manga!.length,
              itemBuilder: (context, index, realIndex) {
                final item = Manga![index];
                final description =
                    Bidi.stripHtmlIfNeeded("${item['description'] ?? "NA"}");
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
                                Color.fromARGB(90, 0, 0, 0),
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
                            "${item['coverImage']['extraLarge']}",
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                  fit: BoxFit.cover,
                                  'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                            },
                            loadingBuilder: (context, child, loadingProgress) {
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
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    ///Heading Text
                                    "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}",
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 255, 0, 0)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    /// Media Type text in this case it is MOVIE
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.book_online,
                                          color:
                                              Color.fromARGB(255, 255, 17, 0),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'MANGA',
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
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        // ignore: prefer_const_constructors
                                        Icon(
                                          Icons.source,
                                          color: const Color.fromARGB(
                                              255, 255, 17, 0),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "${item['source'] ?? "NA"}",
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
                                      '${description}',
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
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            '${item['averageScore'] ?? "NA"}',
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
                                                    builder: (context) =>
                                                        MangaSearchScreen(
                                                            mangaName:
                                                                "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}")));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 255, 17, 0),
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Row(children: [
                                              const Icon(
                                                  Icons.read_more_rounded),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child: const Text('Read',
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
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 15),
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
              },
            ),
          );
  }
}
