import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/pages/ComicScreens/ComicReadScreen.dart';

class ComicIssueSlider extends StatefulWidget {
  const ComicIssueSlider({super.key, this.issues, this.imgUrl});
  final issues;
  final imgUrl;
  @override
  State<ComicIssueSlider> createState() => _ComicIssueSliderState();
}

class _ComicIssueSliderState extends State<ComicIssueSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
          child: const Text(
            "Issues",
            style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 5),
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.issues.length,
              itemBuilder: (BuildContext context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComicReadScreen(
                                  chapterName: widget.issues[index]
                                          ['chaptertitle'] ??
                                      "NA",
                                  chapterId: widget.issues[index]['chapterId'],
                                  comicImg: widget.imgUrl,
                                )));
                  },
                  child: Container(
                    height: 90,
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 120,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          alignment: Alignment.topLeft,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(
                              children: [
                                Image.network(
                                  '${widget.imgUrl}',
                                  height: 90,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  opacity: const AlwaysStoppedAnimation(0.7),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        width: 120,
                                        height: 90,
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
                                  Icons.read_more,
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
                                    '${widget.issues[index]['chaptertitle'] ?? "NA"}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Medium'),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  flex: 0,
                                  child: Text(
                                    '${widget.issues[index]['issueDate'] ?? "NA"}',
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
              }),
        )
      ],
    );
  }
}
