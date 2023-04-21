import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/pages/MangaScreens/MangaReviewScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../pages/AnimeScreens/AnimeReviewScreen.dart';

class MangaReviews extends StatefulWidget {
  const MangaReviews({super.key});

  @override
  State<MangaReviews> createState() => _MangaReviewsState();
}

class _MangaReviewsState extends State<MangaReviews> {
  int pageNumber = 1;
  int count = 5;
  late Map data;
  List? Manga = [];
  bool isLoading = true;
  Future getAnime() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/reviews?page=${pageNumber}&type=MANGA'));

    data = json.decode(response.body);

    setState(() {
      Manga = data['data']['Page']['reviews'];
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
          Container(
            margin: const EdgeInsets.only(top: 10, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manga Reviews",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MangaReviewScreen()));
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
                  height: 650,
                  margin: const EdgeInsets.only(top: 15, left: 5, bottom: 10),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: 5,
                      itemBuilder: (BuildContext context, index) {
                        int timer = 1000;
                        return Shimmer.fromColors(
                            period: Duration(milliseconds: timer),
                            baseColor: const Color.fromARGB(85, 0, 0, 0),
                            highlightColor:
                                const Color.fromARGB(255, 124, 122, 122),
                            child: Container(
                              height: 185,
                              margin: const EdgeInsets.only(
                                  bottom: 20, left: 15, right: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade300,
                              ),
                            ));
                      }),
                )
              : Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 15),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 5,
                      itemBuilder: (BuildContext context, index) {
                        final item = Manga![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FullAnimeReviewAnilist(
                                          animeReview: item,
                                        )));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color.fromARGB(134, 44, 58, 104),
                            ),
                            margin: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 20),
                            padding: const EdgeInsets.only(bottom: 10),
                            //This is container width which include text and image both
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// This cliprect is for images and rating in a stack
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    "${item['media']['bannerImage'] ?? item['media']['coverImage']['extraLarge']}",
                                    height: 100,
                                    width: double.maxFinite,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          height: 100,
                                          width: double.maxFinite,
                                          fit: BoxFit.cover,
                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child;
                                      else {
                                        return Container(
                                          width: double.maxFinite,
                                          height: 100,
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    "Review of "
                                    "${item['media']['title']['english'] ?? item['media']['title']['romaji'] ?? item['media']['title']['userPreferred']}",
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 214, 214, 214)),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    "${item['summary']}",
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 211, 211, 211)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MangaReviewScreen()));
            },
            child: Container(
              width: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "View All",
                    style: TextStyle(fontFamily: "Gilroy-Medium", fontSize: 15),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
