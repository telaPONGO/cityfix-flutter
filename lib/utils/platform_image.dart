import 'platform_image_io.dart'
    if (dart.library.html) 'platform_image_web.dart';

import 'package:flutter/widgets.dart';

Widget buildLocalImage(String path,
    {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  return buildLocalImageImpl(path, fit: fit, width: width, height: height);
}
