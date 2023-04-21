import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/pages/AnimeScreens/AnimeTrailersScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Skeletons/ImagesSliderSkeleton.dart';

class AnimeTrailers extends StatefulWidget {
  const AnimeTrailers({super.key});

  @override
  State<AnimeTrailers> createState() => _AnimeTrailersState();
}

class _AnimeTrailersState extends State<AnimeTrailers> {
  int pageNumber = 1;
  late Map data;
  List? Anime = [];
  bool isLoading = true;
  int count = 30;
  Future getAnime() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.jikan.moe/v4/seasons/upcoming?page=${pageNumber}'));

    data = json.decode(response.body);

    setState(() {
      Anime = data['data'];
      Anime = Anime!.where((item) => item['trailer']['url'] != null).toList();
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
                  "Anime Trailers",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AnimeTrailersScreen()));
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
              ? Container(
                  height: 120,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 20,
                      itemBuilder: (BuildContext context, index) {
                        int timer = 1000;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Shimmer.fromColors(
                              period: Duration(milliseconds: timer),
                              baseColor: const Color.fromARGB(85, 0, 0, 0),
                              highlightColor:
                                  const Color.fromARGB(255, 124, 122, 122),
                              child: Container(
                                height: 120,
                                width: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade300,
                                ),
                              )),
                        );
                      }),
                )
              : Container(
                  height: 180,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: Anime!.length,
                      itemBuilder: (BuildContext context, index) {
                        final item = Anime![index];
                        return GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse('${item['trailer']['url']}'),
                                mode: LaunchMode.externalApplication);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width:
                                220, //This is container width which include text and image both
                            child: Column(
                              children: [
                                /// This cliprect is for images and rating in a stack
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    "${item['trailer']['images']['large_image_url'] ?? item['trailer']['images']['maximum_image_url']}",
                                    height: 120,
                                    width: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          width: 220,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child;
                                      else {
                                        return Container(
                                          width: 220,
                                          height: 120,
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
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${item['title_english'] ?? item['title']}",
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 13,
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
