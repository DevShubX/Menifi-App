import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/VideoPlayers/AnimeVideoPlayer.dart';

class GOGOAnimeDetails extends StatefulWidget {
  GOGOAnimeDetails({super.key, required this.gogoResponse});
  final gogoResponse;
  @override
  State<GOGOAnimeDetails> createState() => _GOGOAnimeDetailsState();
}

class _GOGOAnimeDetailsState extends State<GOGOAnimeDetails> {
  late Map sourcesData;
  List sources = [];
  List sources_bk = [];

  Future getAnimeStreamingLink(String animeStreamId) async {
    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/getlinks?link=$animeStreamId'));

    sourcesData = json.decode(response.body)[0];
    setState(() {
      sources = sourcesData['sources']['sources'];
      sources_bk = sourcesData['sources']['sources_bk'];
    });
  }

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
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Positioned(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 360,
                    child: Image.network(
                      '${widget.gogoResponse['image']}',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                            height: 320,
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
                          style: TextStyle(fontFamily: 'Gilroy-Medium'),
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
                          '${widget.gogoResponse['image']}',
                          fit: BoxFit.cover,
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
                    )),
              ],
            ),

            /// Upper stack for images
            const SizedBox(
              height: 20,
            ),
            Text(
              "${widget.gogoResponse['title'] ?? "NA"}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 25),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextBox(text: widget.gogoResponse['type']),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text: widget.gogoResponse['description'],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text: widget.gogoResponse['genre'],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text: widget.gogoResponse['released'],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text: widget.gogoResponse['status'],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text: widget.gogoResponse['otherName'],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    text:
                        "No. Of Episodes: ${widget.gogoResponse['numOfEpisodes']}",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Episodes",
                    style: TextStyle(
                        fontFamily: "Gilroy-Medium",
                        fontSize: 20,
                        color: Colors.red),
                  )
                ],
              ),
            ),
            Container(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: widget.gogoResponse['episodes'].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return FutureBuilder(
                          future: getAnimeStreamingLink(
                              widget.gogoResponse['episodes'][index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return AnimeVideoPlayer(
                                sources: sources,
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                          },
                        );
                      }));
                    },
                    child: Container(
                      height: 110,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Container(
                            height: 110,
                            width: 130,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            alignment: Alignment.topLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(
                                children: [
                                  Image.network(
                                    '${widget.gogoResponse['image']}',
                                    height: 110,
                                    width: 130,
                                    opacity: const AlwaysStoppedAnimation(0.9),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          width: 130,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Container(
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
                                  const Positioned.fill(
                                      child: Icon(
                                    CupertinoIcons.play_circle,
                                    size: 40,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    flex: 0,
                                    child: Text(
                                      '${widget.gogoResponse['title'] ?? "NA"}',
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
                                      "Episode - ${index + 1}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: 'Gilroy-Medium'),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TextBox extends StatelessWidget {
  const TextBox({super.key, this.text});
  final text;
  @override
  Widget build(BuildContext context) {
    return Text(
      "${text ?? "NA"}".replaceAll("\n", ""),
      style: const TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 16),
    );
  }
}
