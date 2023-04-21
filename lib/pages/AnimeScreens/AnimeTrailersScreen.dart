import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AnimeTrailersScreen extends StatefulWidget {
  const AnimeTrailersScreen({super.key});

  @override
  State<AnimeTrailersScreen> createState() => _AnimeTrailersScreenState();
}

class _AnimeTrailersScreenState extends State<AnimeTrailersScreen> {
  final ScrollController controller = ScrollController();
  int pageNumber = 1;
  List? Anime = [];
  late Map data;
  bool isLoading = true;

  Future getAnimes() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.jikan.moe/v4/seasons/upcoming?page=${pageNumber}'));

    data = json.decode(response.body);
    if (!mounted) return;
    setState(() {
      pageNumber++;
      Anime!.addAll(data['data']);
      Anime = Anime!.where((item) => item['trailer']['url'] != null).toList();
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
          "Anime Trailers",
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
          itemCount: Anime!.length + 1,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < Anime!.length) {
              final item = Anime![index];
              return GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse('${item['trailer']['url']}'),
                      mode: LaunchMode.externalApplication);
                },
                child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.only(
                        top: 15, left: 10, right: 10, bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(131, 41, 39, 39),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(52, 0, 0, 0)),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "${item['trailer']['images']['maximum_image_url'] ?? item['trailer']['images']['large_image_url']}",
                                  height: 100,
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        width: double.maxFinite,
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
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: Image.asset(
                                    'assets/images/youtube-icon.png',
                                    width: 30,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${item['title_english'] ?? item['title']}",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 15.5,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Trailer",
                          style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 13,
                              color: Color.fromARGB(255, 209, 209, 209)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${item['synopsis'] ?? "NA"}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 13,
                              color: Color.fromARGB(255, 209, 209, 209)),
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
