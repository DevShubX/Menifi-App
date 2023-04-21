import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/components/Manga/MangaChapters.dart';
import 'package:menifi/components/Manga/MangaCharacters.dart';
import 'package:menifi/components/Manga/MangaReviewMal.dart';
import 'package:menifi/components/Manga/PopularMangaSlider.dart';
import 'package:menifi/components/Manga/MangaRelatedPhotos.dart';

class MangaDetailsScreen extends StatefulWidget {
  const MangaDetailsScreen(
      {super.key, this.mangaId, this.mangaImgUrl, this.mangaName});
  final mangaId;
  final mangaImgUrl;
  final mangaName;
  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen> {
  var moreMangaInfo;
  var mangaInfo;
  bool isLoading = true;
  int selectedIndex = 0;
  bool showMoreText = false;
  Future getManga(String mangaId) async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/manga/comick/info?mangaId=$mangaId'));
    if (!mounted) return;
    setState(() {
      moreMangaInfo = json.decode(response.body)['result']['moreInfo'];
      mangaInfo = json.decode(response.body)['result']['mangaInfo'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.mangaId != null) {
      getManga(widget.mangaId);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color.fromARGB(255, 28, 28, 28),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.red, size: 30),
          ),
          body: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 185,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.mangaImgUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 185,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                  width: 125,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Text(
                        "${widget.mangaName}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Gilroy-Medium', fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.red)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 360,
                              child: Image.network(
                                '${mangaInfo['image']}',
                                fit: BoxFit.cover,
                                opacity: const AlwaysStoppedAnimation(0.6),
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                      height: 320,
                                      fit: BoxFit.cover,
                                      'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: -5,
                              child: Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30)),
                                    color: Color.fromARGB(255, 28, 28, 28)),
                              )),
                          Positioned(
                              top: 300,
                              left: 40,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Image.asset(
                                      'assets/images/wishlist-icon.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Wishlist",
                                    style:
                                        TextStyle(fontFamily: 'Gilroy-Medium'),
                                  )
                                ],
                              )),
                          Positioned(
                              top: 300,
                              right: 30,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Image.asset(
                                      'assets/images/favourites-icon.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Favourite',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                    ),
                                  )
                                ],
                              )),
                          Positioned(
                              top: 150,
                              child: Container(
                                alignment: Alignment.center,
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    '${mangaInfo['image']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          width: 125,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )),
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                              color: Color.fromARGB(255, 28, 28, 28)),
                          child: Column(

                              /// Main column start from here
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${mangaInfo['title'] ?? widget.mangaName ?? "NA"}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Bold', fontSize: 25),
                                ),
                                Container(
                                  height: 4,
                                  width: 200,
                                  margin: const EdgeInsets.only(top: 20),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 4,
                                      itemBuilder: (BuildContext context,
                                              index) =>
                                          Container(
                                            alignment: Alignment.centerRight,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 255, 0, 0),
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                          )),
                                )
                              ])),
                      Container(
                        width: double.maxFinite,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 20, left: 10),
                        height: 20,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: mangaInfo['genres'].length,
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(
                                        90, 175, 175, 175)),
                                height: 20,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.only(
                                    top: 3, left: 10, right: 10, bottom: 1),
                                child: Text(
                                  '${mangaInfo['genres'][index]}'.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Gilroy-Bold',
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 233, 233, 233),
                                  ),
                                ));
                          },
                        ),
                      ),
                      GestureDetector(
                        // onTap: () {
                        //   Navigator.push(context,
                        //       MaterialPageRoute(builder: (context) {
                        //     return FutureBuilder(
                        //         future: getMovieLink(
                        //             '${data['episodes'][0]['id']}',
                        //             '${data['movieId']}'),
                        //         builder: (context, snapshot) {
                        //           if (snapshot.connectionState ==
                        //               ConnectionState.done) {
                        //             return MovieVidePlayer(
                        //               sources: sources,
                        //               subtitles: subtitles,
                        //             );
                        //           } else {
                        //             return const Center(
                        //               child: CircularProgressIndicator
                        //                   .adaptive(),
                        //             );
                        //           }
                        //         });
                        //   }));
                        // },
                        child: Container(
                          //// Watch now button
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(69, 255, 0, 0),
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.read_more,
                                  size: 35,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const Text('Read',
                                      style: TextStyle(
                                          fontFamily: 'Gilroy-Bold',
                                          fontSize: 22)),
                                )
                              ]),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${mangaInfo['status'] ?? "NA"}',
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 16,
                                      color:
                                          Color.fromARGB(255, 235, 235, 235)),
                                )
                              ],
                            ),
                            const VerticalDivider(
                              thickness: 2,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Release Year',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${moreMangaInfo['year'] ?? "NA"}",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 16),
                                )
                              ],
                            ),
                            const VerticalDivider(
                              thickness: 2,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Score',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${moreMangaInfo['bayesian_rating'] ?? "NA"}',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      fontFamily: 'Gilroy-Medium',
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DefaultTabController(
                        length: 2,
                        child: TabBar(
                            indicatorColor:
                                const Color.fromARGB(255, 255, 0, 0),
                            onTap: (value) {
                              setState(() {
                                selectedIndex = value;
                              });
                            },
                            tabs: const [
                              Tab(
                                text: 'Details',
                              ),
                              Tab(
                                text: 'Chapters',
                              )
                            ]),
                      ),
                      selectedIndex == 0
                          ? Column(
                              children: [
                                Container(
                                  /// Overview Container
                                  margin: const EdgeInsets.only(
                                      top: 20, left: 12, right: 12),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Overview',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 231, 231, 231),
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        Bidi.stripHtmlIfNeeded(
                                                "${moreMangaInfo['desc'] ?? "NA"}")
                                            .trim()
                                            .replaceAll("\n", ""),
                                        textAlign: TextAlign.left,
                                        maxLines: showMoreText ? null : 6,
                                        overflow: showMoreText
                                            ? null
                                            : TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showMoreText = !showMoreText;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: !showMoreText
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: const [
                                                      Text(
                                                        'Read More',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Gilroy-Medium',
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    0,
                                                                    0)),
                                                      ),
                                                      Icon(Icons
                                                          .arrow_drop_down_sharp)
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: const [
                                                      Text('Show Less',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Gilroy-Medium',
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      0,
                                                                      0))),
                                                      Icon(Icons
                                                          .arrow_drop_up_sharp)
                                                    ],
                                                  ),
                                          ))
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Mature Content: ",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 16),
                                      ),
                                      Text(
                                        mangaInfo['matureContent']
                                            ? "YES"
                                            : "NO",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Language: ",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 16),
                                      ),
                                      Text(
                                        moreMangaInfo['iso639_1'] ?? "NA",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Language Name: ",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 16),
                                      ),
                                      Text(
                                        moreMangaInfo['lang_name'] ?? "NA",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Language Native: ",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 16),
                                      ),
                                      Text(
                                        moreMangaInfo['lang_native'] ?? "NA",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Total Chapters: ",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 16),
                                      ),
                                      Text(
                                        "${moreMangaInfo['last_chapter'] ?? "NA"}",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),

                                (moreMangaInfo['links'] != null)
                                    ? MangaCharacters(
                                        malId: moreMangaInfo['links']['mal'],
                                      )
                                    : Container(),

                                (moreMangaInfo['links'] != null)
                                    ? MangaReviewMal(
                                        malId: moreMangaInfo['links']['mal'],
                                        boxColor: const Color.fromARGB(
                                            255, 37, 37, 37),
                                      )
                                    : Container(),

                                (moreMangaInfo['links'] != null)
                                    ? MangaRelatedPhotos(
                                        malId: moreMangaInfo['links']['mal'],
                                      )
                                    : Container(),
                                const SizedBox(
                                  height: 20,
                                ),
                                // // /// Overview Container
                                const PopularMangaSlider(),
                              ],
                            )
                          : MangaChapters(
                              mangaId: moreMangaInfo['hid'],
                              mangaImgUrl: mangaInfo['image'],
                              mangaName: mangaInfo['title'],
                            )
                    ],
                  ),
                )),
    );
  }
}
