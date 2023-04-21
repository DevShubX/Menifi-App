import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Manga/FullScreenImage.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:convert';

import '../Skeletons/ImagesSliderSkeleton.dart';

class AnimeCharacters extends StatefulWidget {
  const AnimeCharacters({super.key, required this.malId});
  final malId;
  @override
  State<AnimeCharacters> createState() => _AnimeCharactersState();
}

class _AnimeCharactersState extends State<AnimeCharacters> {
  List? data;
  bool isLoading = true;
  Future getAnimeCharac(String idMal) async {
    await Future.delayed(const Duration(seconds: 1));
    http.Response response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/anime/$idMal/characters'));

    if (!mounted) return;
    setState(() {
      data = json.decode(response.body)['data'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.malId != null) {
      getAnimeCharac(widget.malId.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          /// Text Portion
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 20, left: 15, right: 20),
            child: const Text(
              "Characters",
              style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: 19,
                  color: Color.fromARGB(255, 231, 231, 231)),
            ),
          ),
          isLoading
              ? Container(
                  height: 135,
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
                                height: 135,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade300,
                                ),
                              )),
                        );
                      }),
                )
              : Container(
                  height: data!.isNotEmpty ? 210 : 20,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: data!.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: data!.length,
                          itemBuilder: (BuildContext context, index) {
                            final item = data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                              imageUrl: item['character']
                                                          ['images']['jpg']
                                                      ['image_url'] ??
                                                  item['character']['images']
                                                      ['webp']['image_url'],
                                            )));
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width:
                                    100, //This is container width which include text and image both
                                child: Column(
                                  children: [
                                    /// This cliprect is for images and rating in a stack
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        "${item['character']['images']['jpg']['image_url'] ?? item['character']['images']['webp']['image_url']}",
                                        height: 145,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                              width: 100,
                                              height: 145,
                                              fit: BoxFit.cover,
                                              'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Container(
                                              width: 100,
                                              height: 145,
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
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        "${item['character']['name'] ?? "NA"}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy-Medium',
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${item['role'] ?? "NA"}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Gilroy-Medium',
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 204, 204, 204),
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
                            'No Info Available',
                            style: TextStyle(
                                fontFamily: 'Gilroy-Medium',
                                color: Colors.grey),
                          ),
                        ),
                ),
        ],
      ),
    );
  }
}
