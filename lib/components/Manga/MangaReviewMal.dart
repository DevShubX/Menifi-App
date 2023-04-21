import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../Anime/AnimeReviewMal.dart';

class MangaReviewMal extends StatefulWidget {
  const MangaReviewMal(
      {super.key, required this.malId, required this.boxColor});
  final malId;
  final Color boxColor;
  @override
  State<MangaReviewMal> createState() => _MangaReviewMalState();
}

class _MangaReviewMalState extends State<MangaReviewMal> {
  List data = [];
  bool isLoading = true;

  Future getAnimeReviews(String idMal) async {
    await Future.delayed(const Duration(seconds: 2));
    http.Response response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/manga/$idMal/reviews'));

    if (!mounted) return;
    setState(() {
      data = json.decode(response.body)['data'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.malId != null) {
      getAnimeReviews(widget.malId.toString());
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Text Portion
          Container(
            margin: const EdgeInsets.only(top: 10, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reviews",
                  style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      fontSize: 19,
                      color: Color.fromARGB(255, 231, 231, 231)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllReviewsForAnime(
                                  ReviewList: data,
                                  boxColor: widget.boxColor,
                                )));
                  },
                  child: const Text(
                    "More",
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
                  height: 500,
                  margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (BuildContext context, index) {
                        int timer = 1000;
                        return Shimmer.fromColors(
                            period: Duration(milliseconds: timer),
                            baseColor: const Color.fromARGB(85, 0, 0, 0),
                            highlightColor:
                                const Color.fromARGB(255, 124, 122, 122),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.grey.shade300,
                              ),
                            ));
                      }),
                )
              : data.isNotEmpty
                  ? ListView.builder(
                      padding:
                          const EdgeInsets.only(top: 10, left: 20, right: 20),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 2,
                      itemBuilder: (BuildContext context, index) {
                        final item = data[index];
                        final date = item['date'];
                        DateTime dateTime = DateTime.parse(date);
                        String formatedDate =
                            DateFormat('MMM d, y').format(dateTime);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullAnimeReviewMal(
                                    animeReview: item,
                                    formattedDate: formatedDate.toString(),
                                    bgColor: widget.boxColor,
                                  ),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: widget.boxColor,
                                borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.only(
                                top: 10, left: 15, right: 15, bottom: 10),
                            //This is container width which include text and image both
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        "${item['user']['images']['jpg']['image_url'] ?? item['character']['images']['webp']['image_url']}",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              color: const Color.fromARGB(
                                                  85, 0, 0, 0),
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
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['user']['username'] ?? "NA"}',
                                          style: const TextStyle(
                                              fontFamily: 'Gilroy-Bold',
                                              fontSize: 17),
                                        ),
                                        Text(
                                          'Overall Rating ${item['score'] ?? "NA"}',
                                          style: const TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 13,
                                              color: Colors.grey),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${item['review'] ?? "NA"}",
                                  maxLines: 7,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium'),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatedDate,
                                      style: const TextStyle(
                                          fontFamily: 'Gilroy-Medium',
                                          color: Colors.grey),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '${item['reactions']['overall'] ?? "NA"}',
                                            style: const TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                color: Colors.grey)),
                                        const Icon(
                                            Icons
                                                .keyboard_double_arrow_up_rounded,
                                            size: 17,
                                            color: Colors.grey)
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      })
                  : Container(
                      margin: const EdgeInsets.only(left: 15, top: 10),
                      child: const Text(
                        "No Reviews Available",
                        style: TextStyle(
                            fontFamily: 'Gilroy-Medium', color: Colors.grey),
                      ),
                    ),
        ],
      ),
    );
  }
}
