import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/pages/MangaScreens/MangaReadScreen.dart';
import '../Anime/AnimeEpisodesSlider.dart';

class MangaChapters extends StatefulWidget {
  const MangaChapters(
      {super.key, this.mangaId, this.mangaImgUrl, this.mangaName});
  final mangaId;
  final mangaImgUrl;
  final mangaName;
  @override
  State<MangaChapters> createState() => _MangaChaptersState();
}

class _MangaChaptersState extends State<MangaChapters> {
  final ScrollController controller = ScrollController();
  List mangaChapters = [];
  bool isLoading = true;
  int pageNumber = 1;
  var totalChapters;
  Future getManga(String mangaId) async {
    if (mangaChapters.length == totalChapters) return;
    http.Response response = await http.get(Uri.parse(
        'https://api.comick.app/comic/$mangaId/chapters?page=$pageNumber&lang=en,uk'));
    if (!mounted) return;
    setState(() {
      pageNumber++;
      mangaChapters.addAll(json.decode(response.body)['chapters']);
      totalChapters = json.decode(response.body)['total'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.mangaId != null) {
      getManga(widget.mangaId);
    }
    super.initState();
    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        getManga(widget.mangaId);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const EpisodesShimmer()
        : mangaChapters.isEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text(
                  "No Chapters Available",
                  style: TextStyle(
                      fontFamily: 'Gilroy-Medium',
                      color: Colors.grey,
                      fontSize: 20),
                ),
              )
            : Column(
                children: [
                  Container(
                    height: 600,
                    margin: const EdgeInsets.only(top: 10, left: 5),
                    child: ListView.builder(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 5),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: mangaChapters.length + 1,
                        itemBuilder: (BuildContext context, index) {
                          if (index < mangaChapters.length) {
                            final date = mangaChapters[index]['created_at'];
                            var formated = "NA";
                            if (date != null) {
                              DateTime dateTime = DateTime.parse(date);
                              formated =
                                  DateFormat('EEE, MMMM d, y').format(dateTime);
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MangaReadScreen(
                                              chapterId: mangaChapters[index]
                                                  ['hid'],
                                              chapterName: mangaChapters[index]
                                                  ['title'],
                                              chapterNum:
                                                  "Chapter: ${mangaChapters[index]['chap'] ?? "NA"}",
                                              mangaImgUrl: widget.mangaImgUrl,
                                            )));
                              },
                              child: Container(
                                height: 160,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 160,
                                      width: 130,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      alignment: Alignment.topLeft,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          '${widget.mangaImgUrl}',
                                          height: 160,
                                          width: 130,
                                          opacity:
                                              const AlwaysStoppedAnimation(0.9),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.network(
                                                width: 160,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Container(
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
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                              flex: 0,
                                              child: Text(
                                                '${widget.mangaName}',
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                              flex: 0,
                                              child: Text(
                                                "Chapter: ${mangaChapters[index]['chap'] ?? "NA"}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Gilroy-Medium'),
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                              flex: 0,
                                              child: Text(
                                                "${mangaChapters[index]['title'] ?? "NA"}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Gilroy-Medium'),
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                              "${mangaChapters[index]['lang'] ?? "Lang : NA"}"
                                                  .toUpperCase()),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            formated,
                                            style: const TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            if (mangaChapters.length == totalChapters) {
                              return Container();
                            } else {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                          }
                        }),
                  )
                ],
              );
  }
}
