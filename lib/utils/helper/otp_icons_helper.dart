import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

class OtpIconsHelper {
  static const double _minimumIconContrastRatio = 3.0;

  static Icon getIcon(
    BuildContext context,
    String? iconKey, {
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = backgroundColor ?? colorScheme.surface;
    final icon = simpleIcons[iconKey] ?? simpleIcons['default']!;
    final foreground = icon.color ?? colorScheme.onSurface;

    final color =
        colorScheme.brightness == Brightness.light ||
            _contrastRatio(foreground, background) >= _minimumIconContrastRatio
        ? foreground
        : colorScheme.onSurface;

    return Icon(icon.icon, color: color);
  }

  static double _contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();

    final lighter = max(foregroundLuminance, backgroundLuminance);
    final darker = min(foregroundLuminance, backgroundLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  static Map<String, Icon> find(String toFind) {
    toFind = toFind.replaceAll(' ', '').toLowerCase();

    return Map.from(simpleIcons)
      ..removeWhere((key, value) => !key.contains(toFind));
  }

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
