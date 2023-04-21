import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class AnimeAdditionalVideos extends StatefulWidget {
  const AnimeAdditionalVideos({super.key, this.malId});
  final malId;
  @override
  State<AnimeAdditionalVideos> createState() => _AnimeAdditionalVideosState();
}

class _AnimeAdditionalVideosState extends State<AnimeAdditionalVideos> {
  late List promo = [];
  late List musicVid = [];
  bool isLoading = true;
  late Map data;
  Future getanime(String idMal) async {
    await Future.delayed(const Duration(seconds: 2));
    http.Response response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/anime/$idMal/videos'));

    data = json.decode(response.body);
    if (!mounted) return;
    if (response.statusCode == 200) {
      setState(() {
        promo = data['data']['promo'];
        musicVid = data['data']['music_videos'];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    if (widget.malId != null) {
      getanime(widget.malId.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Text Portion
            Container(
              margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Anime Trailers",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Bold',
                        fontSize: 19,
                        color: Color.fromARGB(255, 231, 231, 231)),
                  ),
                ],
              ),
            ),
            isLoading
                ? Container(
                    height: 120,
                    margin: const EdgeInsets.only(top: 15, left: 5),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
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
                        }))
                : Container(
                    height: promo.isNotEmpty ? 150 : 20,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 15, left: 5),
                    child: promo.isNotEmpty
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: promo.length,
                            itemBuilder: (BuildContext context, index) {
                              final item = promo[index];
                              return GestureDetector(
                                onTap: () {
                                  launchUrl(
                                      Uri.parse('${item['trailer']['url']}'),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width:
                                      220, //This is container width which include text and image both
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// This cliprect is for images and rating in a stack
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.network(
                                              "${item['trailer']['images']['large_image_url'] ?? item['trailer']['images']['maximum_image_url']}",
                                              height: 120,
                                              width: 220,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                    width: 220,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Container(
                                                    width: 220,
                                                    height: 120,
                                                    color: const Color.fromARGB(
                                                        85, 0, 0, 0),
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive(),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 0,
                                              right: 10,
                                              child: Image.asset(
                                                'assets/images/youtube-icon.png',
                                                width: 50,
                                                height: 50,
                                              ))
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "${item['title'] ?? "NA"}",
                                          style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        : Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "No Trailers Available",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Gilroy-Medium'),
                            ),
                          ),
                  )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Text Portion
            Container(
              margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Music Videos",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Bold',
                        fontSize: 19,
                        color: Color.fromARGB(255, 231, 231, 231)),
                  ),
                ],
              ),
            ),
            isLoading
                ? Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 15, left: 5),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
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
                        }))
                : Container(
                    height: musicVid.isNotEmpty ? 150 : 20,
                    margin: const EdgeInsets.only(top: 15, left: 5),
                    child: musicVid.isNotEmpty
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: musicVid.length,
                            itemBuilder: (BuildContext context, index) {
                              final item = musicVid[index];
                              return GestureDetector(
                                onTap: () {
                                  launchUrl(
                                      Uri.parse('${item['video']['url']}'),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width:
                                      220, //This is container width which include text and image both
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// This cliprect is for images and rating in a stack
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.network(
                                              "${item['video']['images']['large_image_url'] ?? item['video']['images']['maximum_image_url']}",
                                              height: 120,
                                              width: 220,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                    width: 220,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Container(
                                                    width: 220,
                                                    height: 120,
                                                    color: const Color.fromARGB(
                                                        85, 0, 0, 0),
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive(),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 0,
                                              right: 10,
                                              child: Image.asset(
                                                'assets/images/youtube-icon.png',
                                                width: 50,
                                                height: 50,
                                              ))
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "${item['title'] ?? "NA"}",
                                          style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        : Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "No Music Videos Available",
                              style: TextStyle(
                                  fontFamily: 'Gilroy-Medium',
                                  color: Colors.grey),
                            ),
                          ),
                  )
          ],
        )
      ],
    );
  }
}
