import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

class OtpIconsHelper {
  static String findFirst(String toFind) {
    toFind = toFind.replaceAll(' ', '').toLowerCase();

    return simpleIcons.keys.firstWhere(
      (v) => v.contains(toFind),
      orElse: () => 'default',
    );
  }

  static Map<String, Icon> findBestMatch(String toFind) {
    toFind = toFind.replaceAll(' ', '').toLowerCase();

    Map<String, Icon> iconsBestMatch = {};

    simpleIcons.forEach((key, value) {
      if (iconsBestMatch.length != 3 && key.contains(toFind)) {
        iconsBestMatch[key] = value;
      }
    });

    return iconsBestMatch;
  }

  static final Map<String, Icon> simpleIcons = SimpleIcons.values.map((
    iconKey,
    iconData,
  ) {
    return MapEntry<String, Icon>(
      iconKey,
      Icon(iconData, color: SimpleIconColors.values[iconKey]),
    );
  })..putIfAbsent('default', () => const Icon(Icons.vpn_key));
}
