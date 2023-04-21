import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shimmer/shimmer.dart';

class CarouselSlideSkeleton extends StatefulWidget {
  const CarouselSlideSkeleton({super.key});

  @override
  State<CarouselSlideSkeleton> createState() => _CarouselSlideSkeletonState();
}

class _CarouselSlideSkeletonState extends State<CarouselSlideSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60),
      height: 300,
      child: Shimmer.fromColors(
        baseColor: Color.fromARGB(85, 0, 0, 0),
        highlightColor: Color.fromARGB(255, 124, 122, 122),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
