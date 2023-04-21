import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:menifi/components/Comic/ComicIssueSlider.dart';

class ComicDetailScreen extends StatefulWidget {
  const ComicDetailScreen({super.key, this.comicName, this.comicId});
  final comicName;
  final comicId;
  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  var comicInfo;
  bool isLoading = true;
  bool showMoreText = false;
  Future getComic(String comicId) async {
    http.Response response = await http.get(
        Uri.parse('https://comics-api-wine.vercel.app/api/info?id=$comicId'));

    setState(() {
      comicInfo = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.comicId != null) {
      getComic(widget.comicId);
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
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/M-Logo.png',
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                  width: 125,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                            },
                          ),
                        ),
                      ),
                      Text(
                        "${widget.comicName}",
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
                                '${comicInfo['image']}',
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
                                    '${comicInfo['image']}',
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
                                  '${comicInfo['title'] ?? "NA"}',
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
                          child: Text('${comicInfo['genres'][0]}'.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Gilroy-Bold',
                                fontSize: 13,
                                color: Color.fromARGB(255, 233, 233, 233),
                              ))),
                      GestureDetector(
                        child: Container(
                          //// Read Now button
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
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        /// Overview Container
                        margin:
                            const EdgeInsets.only(top: 20, left: 12, right: 12),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overview',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 231, 231, 231),
                                  fontFamily: 'Gilroy-Bold',
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              Bidi.stripHtmlIfNeeded(
                                      "${comicInfo['description'] ?? "NA"}")
                                  .trim()
                                  .replaceAll("\n", ""),
                              textAlign: TextAlign.left,
                              maxLines: showMoreText ? null : 6,
                              overflow:
                                  showMoreText ? null : TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium', fontSize: 14),
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
                                                  fontFamily: 'Gilroy-Medium',
                                                  color: Color.fromARGB(
                                                      255, 255, 0, 0)),
                                            ),
                                            Icon(Icons.arrow_drop_down_sharp)
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text('Show Less',
                                                style: TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    color: Color.fromARGB(
                                                        255, 255, 0, 0))),
                                            Icon(Icons.arrow_drop_up_sharp)
                                          ],
                                        ),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 10, left: 12, right: 12),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 231, 231, 231),
                                  fontFamily: 'Gilroy-Bold',
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${comicInfo['status'] ?? "NA"}",
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium', fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 12, right: 12),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Text(
                              'Author: ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 231, 231, 231),
                                  fontFamily: 'Gilroy-Bold',
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${comicInfo['authorName'] ?? "NA"}",
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium', fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 12, right: 12),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Other Name',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 231, 231, 231),
                                  fontFamily: 'Gilroy-Bold',
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${comicInfo['othername'] ?? "NA"}",
                              style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium', fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      ComicIssueSlider(
                        issues: comicInfo['chapters'],
                        imgUrl: comicInfo['image'],
                      )
                    ],
                  ),
                )),
    );
  }
}
