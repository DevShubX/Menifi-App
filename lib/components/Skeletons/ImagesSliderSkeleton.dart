import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shimmer/shimmer.dart';

class ImagesSliderSkeleton extends StatefulWidget {
  const ImagesSliderSkeleton({super.key});

  @override
  State<ImagesSliderSkeleton> createState() => _ImagesSliderSkeletonState();
}

class _ImagesSliderSkeletonState extends State<ImagesSliderSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      margin: EdgeInsets.only(top: 15, left: 5),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, index) {
            int timer = 1000;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Shimmer.fromColors(
                  period: Duration(milliseconds: timer),
                  baseColor: Color.fromARGB(85, 0, 0, 0),
                  highlightColor: Color.fromARGB(255, 124, 122, 122),
                  child: Container(
                    height: 185,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade300,
                    ),
                  )),
            );
          }),
    );
  }
}
