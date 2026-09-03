import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class OtpManagerAnimateChangeIcon extends StatefulWidget {
  const OtpManagerAnimateChangeIcon({
    required this.icons,
    this.animateDuration = const Duration(milliseconds: 300),
    this.initialIndex = 0,
    this.animationController,
    this.scaleAnimationCurve = Curves.linear,
    this.rotateAnimationCurve = Curves.linear,
    this.rotateBeginAngle = -pi / 2,
    this.rotateEndAngle = 0.0,
    this.onTap,
    super.key,
  }) : assert(icons.length >= 2, 'icons must contain at least 2 items');

  /// The list of icons to show cyclically.
  final List<PhosphorIcon> icons;

  /// Animation duration.
  final Duration animateDuration;

  /// Initial visible icon index.
  final int initialIndex;

  /// Optional external controller.
  final AnimationController? animationController;

  /// Scale animation curve.
  final Curve scaleAnimationCurve;

  /// Rotation animation curve.
  final Curve rotateAnimationCurve;

  /// Callback called on tap.
  final void Function(int index)? onTap;

  /// Initial angle of rotation animation.
  final double rotateBeginAngle;

  /// Final angle of rotation animation.
  final double rotateEndAngle;

  @override
  OtpManagerAnimateChangeIconState createState() =>
      OtpManagerAnimateChangeIconState();
}

class OtpManagerAnimateChangeIconState
    extends State<OtpManagerAnimateChangeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final bool _isControllerInjected;

  late int _currentIndex;
  late int _nextIndex;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex % widget.icons.length;
    _nextIndex = (_currentIndex + 1) % widget.icons.length;

    if (widget.animationController != null) {
      _controller = widget.animationController!;
      _isControllerInjected = true;
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: widget.animateDuration,
      );
      _isControllerInjected = false;
    }

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _nextIndex;
          _nextIndex = (_currentIndex + 1) % widget.icons.length;
          _isAnimating = false;
        });

        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(covariant OtpManagerAnimateChangeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icons != widget.icons &&
        _currentIndex >= widget.icons.length) {
      _currentIndex = 0;
      _nextIndex = widget.icons.length > 1 ? 1 : 0;
    }
  }

  void next() {
    if (_isAnimating || widget.icons.length < 2) return;

    setState(() {
      _nextIndex = (_currentIndex + 1) % widget.icons.length;
      _isAnimating = true;
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    if (!_isControllerInjected) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> scaleIn =
        CurvedAnimation(
          parent: _controller,
          curve: widget.scaleAnimationCurve,
        ).drive(
          Tween<double>(
            begin: _controller.lowerBound,
            end: _controller.upperBound,
          ),
        );

    final Animation<double> scaleOut =
        CurvedAnimation(
          parent: _controller,
          curve: widget.scaleAnimationCurve,
        ).drive(
          Tween<double>(
            begin: _controller.upperBound,
            end: _controller.lowerBound,
          ),
        );

    final Animation<double> rotateIn =
        CurvedAnimation(
          parent: _controller,
          curve: widget.rotateAnimationCurve,
        ).drive(
          Tween<double>(
            begin: widget.rotateBeginAngle,
            end: widget.rotateEndAngle,
          ),
        );

    final Animation<double> rotateOut =
        CurvedAnimation(
          parent: _controller,
          curve: widget.rotateAnimationCurve,
        ).drive(
          Tween<double>(
            begin: widget.rotateEndAngle,
            end: widget.rotateBeginAngle,
          ),
        );

    final currentIcon = widget.icons[_currentIndex];
    final nextIcon = widget.icons[_nextIndex];

    return GestureDetector(
      onTap: () {
        widget.onTap?.call(_nextIndex);
        next();
      },
      child: _isAnimating
          ? Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scaleIn.value,
                  child: Transform.rotate(
                    angle: rotateIn.value,
                    child: nextIcon,
                  ),
                ),
                Transform.scale(
                  scale: scaleOut.value,
                  child: Transform.rotate(
                    angle: rotateOut.value,
                    child: currentIcon,
                  ),
                ),
              ],
            )
          : currentIcon,
    );
  }
}
