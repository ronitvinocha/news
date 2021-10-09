import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GenericShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const GenericShimmer({Key key, this.height, this.width, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey[400],
      enabled: true,
      loop: 3,
      child: Container(
        height: height,
        width: width == null ? double.maxFinite : width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
        ),
      ),
    );
  }
}
