import 'dart:io';
import 'package:flutter/material.dart';

Widget buildLocalImageImpl(String path,
    {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFE0E7FF),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.blue),
        ),
      );
    },
  );
}
