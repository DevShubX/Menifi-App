import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AnimeReviewScreen extends StatefulWidget {
  const AnimeReviewScreen({super.key});

  @override
  State<AnimeReviewScreen> createState() => _AnimeReviewScreenState();
}

class _AnimeReviewScreenState extends State<AnimeReviewScreen> {
  final ScrollController controller = ScrollController();
  int pageNumber = 1;
  List? Anime = [];
  late Map data;
  bool isLoading = true;

  Future getAnimes() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/reviews?page=${pageNumber}&type=ANIME'));

    data = json.decode(response.body);
    if (!mounted) return;
    setState(() {
      pageNumber++;
      Anime!.addAll(data['data']['Page']['reviews']);
      isLoading = false;
    });
  }

  @override
  void initState() {
    getAnimes();
    super.initState();

    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        getAnimes();
      }
    });
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
      backgroundColor: const Color.fromARGB(223, 20, 1, 44),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Anime Reviews",
          style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => super.widget));
          });
        },
        child: Container(
          child: ListView.builder(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: Anime!.length + 1,
              itemBuilder: (BuildContext context, index) {
                if (index < Anime!.length) {
                  final item = Anime![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullAnimeReviewAnilist(
                                    animeReview: item,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromARGB(134, 53, 53, 53),
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
                              "${item['media']['bannerImage']}",
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
                                    height: 100,
                                    color: const Color.fromARGB(85, 0, 0, 0),
                                    child: const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
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
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              "Review of "
                              "${item['media']['title']['english'] ?? item['media']['title']['romaji'] ?? item['media']['title']['userPreferred']}",
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Bold',
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 216, 215, 215)),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              "${item['summary']}",
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium',
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 216, 215, 215)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
              }),
        ),
      ),
    ));
  }
}

class FullAnimeReviewAnilist extends StatefulWidget {
  const FullAnimeReviewAnilist({super.key, this.animeReview});
  final animeReview;
  @override
  State<FullAnimeReviewAnilist> createState() => _FullAnimeReviewAnilistState();
}

class _FullAnimeReviewAnilistState extends State<FullAnimeReviewAnilist> {
  @override
  void initState() {
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
      backgroundColor: Color.fromARGB(255, 21, 31, 46),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Full Review",
          style: TextStyle(
            fontFamily: 'Gilroy-Medium',
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  "${widget.animeReview['media']['bannerImage'] ?? widget.animeReview['media']['coverImage']['extraLarge']}",
                  height: 130,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                        height: 130,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                        'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null)
                      return child;
                    else {
                      return Container(
                        height: 130,
                        color: const Color.fromARGB(85, 0, 0, 0),
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(
                "Review of "
                "${widget.animeReview['media']['title']['english'] ?? widget.animeReview['media']['title']['romaji'] ?? widget.animeReview['media']['title']['userPreferred']}",
                style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 14,
                    color: Color.fromARGB(255, 231, 231, 231)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(
                "${widget.animeReview['summary']}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: 13,
                    color: Color.fromARGB(255, 216, 215, 215)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                Bidi.stripHtmlIfNeeded("${widget.animeReview['body']}")
                    .replaceAll("#", ""),
                style: const TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Color.fromARGB(255, 231, 231, 231)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Source : Anilist",
              style: TextStyle(fontFamily: 'Gilroy-Medium'),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    ));
  }
}
