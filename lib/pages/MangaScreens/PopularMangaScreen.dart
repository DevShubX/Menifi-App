import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/MangaScreens/MangaSearchScreen.dart';

class PopularMangaScreen extends StatefulWidget {
  const PopularMangaScreen({super.key});

  @override
  State<PopularMangaScreen> createState() => _PopularMangaScreenState();
}

class _PopularMangaScreenState extends State<PopularMangaScreen> {
  final ScrollController controller = ScrollController();
  int pageNumber = 1;
  int count = 20;
  List? Manga = [];
  late Map data;
  bool isLoading = true;

  Future getAnimes() async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/popular/manga?page=${pageNumber}&count=$count'));

    data = json.decode(response.body);
    if (!mounted) return;
    setState(() {
      pageNumber++;
      Manga!.addAll(data['data']['Page']['media']);
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
          "Popular Manga",
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
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          controller: controller,
          physics: const BouncingScrollPhysics(),
          itemCount: Manga!.length + 1,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < Manga!.length) {
              final item = Manga![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MangaSearchScreen(
                              mangaName:
                                  "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}")));
                },
                child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.only(
                        top: 15, left: 10, right: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: item['coverImage']['color'] != null
                          ? Color(int.parse(item['coverImage']['color']
                                  .toString()
                                  .replaceAll("#", "0XFF")))
                              .withOpacity(0.5)
                          : const Color.fromARGB(193, 41, 39, 39),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 140,
                          width: 100,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(52, 0, 0, 0)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${item['coverImage']['large']}',
                              width: 100,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                    width: 100,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${item['title']['romaji'] ?? item['title']['english'] ?? item['title']['userPreferred']}",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Gilroy-Bold',
                                    fontSize: 15.5,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                '${item['source'] ?? "NA"}',
                                style: const TextStyle(
                                    fontFamily: 'Gilroy-Medium',
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 209, 209, 209)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${item['averageScore'] ?? "NA"}",
                                style: const TextStyle(
                                    fontFamily: 'Gilroy-Medium',
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 209, 209, 209)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 20,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: item['genres'].length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color.fromARGB(
                                                90, 175, 175, 175)),
                                        height: 20,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.only(
                                            top: 3,
                                            left: 3,
                                            right: 3,
                                            bottom: 1),
                                        child: Text(
                                          '${item['genres'][index]}'
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            fontSize: 13,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                        ));
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },
        ),
      ),
    ));
  }
}
