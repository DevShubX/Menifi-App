import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:menifi/components/Manga/FullScreenImage.dart';

class ComicReadScreen extends StatefulWidget {
  const ComicReadScreen(
      {super.key, this.chapterName, this.chapterId, this.comicImg});
  final chapterName;
  final chapterId;
  final comicImg;
  @override
  State<ComicReadScreen> createState() => _ComicReadScreenState();
}

class _ComicReadScreenState extends State<ComicReadScreen> {
  List pages = [];
  bool isLoading = true;

  Future getComic(String chapterId) async {
    http.Response response = await http.get(Uri.parse(
        'https://comics-api-wine.vercel.app/api/read?chapterId=$chapterId'));

    if (!mounted) return;
    setState(() {
      pages = json.decode(response.body)['pages'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.chapterId != null) {
      getComic(widget.chapterId);
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
      backgroundColor: const Color.fromARGB(255, 14, 13, 13),
      appBar: AppBar(
        title: Text(
          "${widget.chapterName ?? "NA"}",
          style: const TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                        widget.comicImg,
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
                    "${widget.chapterName ?? "NA"}",
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
          : pages.isNotEmpty
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: false,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                      imageUrl: pages[index]['page'],
                                    )));
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Image.network(pages[index]['page'],
                                  errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                              }, loadingBuilder:
                                      (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.7,
                                    color: const Color.fromARGB(85, 0, 0, 0),
                                    child: const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  );
                                }
                              }),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${pages[index]['index']} / ${pages.length}",
                                style: const TextStyle(
                                    fontFamily: 'Gilroy-Medium', fontSize: 17),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                thickness: 2,
                              )
                            ],
                          )),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "No Pages Available",
                        style: TextStyle(
                            fontFamily: 'Gilroy-Medium', fontSize: 19),
                      )
                    ],
                  ),
                ),
    ));
  }
}
