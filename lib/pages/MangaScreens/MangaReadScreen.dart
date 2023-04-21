import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MangaReadScreen extends StatefulWidget {
  const MangaReadScreen(
      {super.key,
      this.chapterId,
      this.chapterNum,
      this.chapterName,
      this.mangaImgUrl});
  final chapterId;
  final chapterNum;
  final chapterName;
  final mangaImgUrl;
  @override
  State<MangaReadScreen> createState() => _MangaReadScreenState();
}

class _MangaReadScreenState extends State<MangaReadScreen> {
  List pages = [];
  var chapterInfo;
  bool isLoading = true;
  Future getManga(String chapterId) async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/manga/comick/read?chapterId=$chapterId'));
    if (!mounted) return;
    setState(() {
      chapterInfo = json.decode(response.body)['result'];
      pages = json.decode(response.body)['pages'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.chapterId != null) {
      getManga(widget.chapterId);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.chapterNum ?? "NA"}",
              style: const TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 16),
            ),
            Text(
              "${widget.chapterName ?? "NA"}",
              style: const TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 16),
            ),
          ],
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
                    "${widget.chapterNum ?? "NA"}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Gilroy-Medium', fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
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
                    return Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            Image.network(pages[index]['img'],
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  color: const Color.fromARGB(85, 0, 0, 0),
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              }
                            }),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${pages[index]['page'] + 1} / ${pages.length}",
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
                        ));
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
