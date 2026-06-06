import 'package:flutter/material.dart';

Widget buildLocalImageImpl(String path,
    {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  return SizedBox(
    width: width,
    height: height,
    child: Container(
      color: const Color(0xFFF0F4FF),
      child: const Center(
        child: Icon(
          Icons.image,
          size: 48,
          color: Color(0xFF6B81C5),
        ),
      ),
    ),
  );
}
