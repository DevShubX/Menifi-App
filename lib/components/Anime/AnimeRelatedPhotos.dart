import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'dart:async';

import '../Manga/FullScreenImage.dart';
import '../Skeletons/ImagesSliderSkeleton.dart';

class AnimeRelatedPhotos extends StatefulWidget {
  const AnimeRelatedPhotos({super.key, this.malId});
  final malId;
  @override
  State<AnimeRelatedPhotos> createState() => _AnimeRelatedPhotosState();
}

class _AnimeRelatedPhotosState extends State<AnimeRelatedPhotos> {
  List? data;
  bool isLoading = true;
  Future getpicture(String idMal) async {
    await Future.delayed(const Duration(seconds: 4));
    http.Response response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/anime/$idMal/pictures'));
    if (!mounted) return;
    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body)['data'];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    if (widget.malId != null) {
      getpicture(widget.malId.toString());
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Text Portion
          Container(
            margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
            child: const Text(
              "Related Photos",
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
                  height: data!.isNotEmpty ? 145 : 20,
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
                                            imageUrl: item['jpg']
                                                    ['large_image_url'] ??
                                                item['webp']
                                                    ['large_image_url'])));
                              },
                              //This is container width which include text and image both
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    "${item['jpg']['large_image_url'] ?? item['webp']['large_image_url']}",
                                    height: 145,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          width: 100,
                                          height: 145,
                                          fit: BoxFit.cover,
                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child;
                                      else {
                                        return Container(
                                          width: 100,
                                          height: 145,
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
                              ),
                            );
                          })
                      : Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: const Text(
                            "No Photos Available",
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
