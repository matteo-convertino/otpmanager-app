import 'package:flutter/material.dart';

class OtpManagerAnimatedGradient extends StatefulWidget {
  const OtpManagerAnimatedGradient({
    super.key,
    required this.primaryColors,
    required this.secondaryColors,
    this.child,
    this.primaryBegin = Alignment.topLeft,
    this.primaryEnd = Alignment.topRight,
    this.secondaryBegin = Alignment.bottomLeft,
    this.secondaryEnd = Alignment.bottomRight,
    this.primaryBeginGeometry,
    this.primaryEndGeometry,
    this.secondaryBeginGeometry,
    this.secondaryEndGeometry,
    this.textDirectionForGeometry = TextDirection.ltr,
    this.controller,
    this.duration = const Duration(seconds: 4),
    this.animateAlignments = true,
    this.reverse = true,
    this.repeat = true,
    this.curve = Curves.easeInOut,
    this.borderRadius,
    this.height,
    this.width,
  }) : assert(primaryColors.length >= 2),
       assert(primaryColors.length == secondaryColors.length);

  /// [controller]: pass this to have a fine control over the [Animation]
  final AnimationController? controller;

  /// [curve]: The curve to use for the animation.
  /// By default its value is [Curves.easeInOut]
  final Curve curve;

  /// [duration]: Time to switch between [Gradient].
  /// By default its value is [Duration(seconds:4)]
  final Duration duration;

  /// [primaryColors]: These will be the starting colors of the [Animation].
  final List<Color> primaryColors;

  /// [secondaryColors]: These Colors are those in which the [primaryColors] will transition into.
  final List<Color> secondaryColors;

  /// [primaryBegin]: This is begin [Alignment] for [primaryColors].
  /// By default its value is [Alignment.topLeft]
  final Alignment primaryBegin;

  /// [primaryBegin]: This is end [Alignment] for [primaryColors].
  /// By default its value is [Alignment.topRight]
  final Alignment primaryEnd;

  /// [secondaryBegin]: This is begin [Alignment] for [secondaryColors].
  /// By default its value is [Alignment.bottomLeft]
  final Alignment secondaryBegin;

  /// [secondaryEnd]: This is end [Alignment] for [secondaryColors].
  /// By default its value is [Alignment.bottomRight]
  final Alignment secondaryEnd;

  /// Alternatively you can use [primaryBeginGeometry] over [primaryBegin] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [primaryBeginGeometry] will have higher priority than [primaryBegin]
  final AlignmentGeometry? primaryBeginGeometry;

  /// Alternatively you can use [primaryEndGeometry] over [primaryEnd] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [primaryEndGeometry] will have higher priority than [primaryEnd]
  final AlignmentGeometry? primaryEndGeometry;

  /// Alternatively you can use [secondaryBeginGeometry] over [secondaryBegin] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [secondaryBeginGeometry] will have higher priority than [secondaryBegin]
  final AlignmentGeometry? secondaryBeginGeometry;

  /// Alternatively you can use [secondaryEndGeometry] over [secondaryEnd] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [secondaryEndGeometry] will have higher priority than [secondaryEnd]
  final AlignmentGeometry? secondaryEndGeometry;

  /// This is the [TextDirection] which is gonna be used to resolve [AlignmentGeometry] passed through
  /// [primaryBeginGeometry], [primaryEndGeometry], [secondaryBeginGeometry], [secondaryEndGeometry]
  final TextDirection textDirectionForGeometry;

  /// [animateAlignments]: set to false if you don't want to animate the alignments.
  /// This can provide you way cooler animations
  final bool animateAlignments;

  /// [reverse]: set it to false if you don't want to reverse the animation.
  /// using that it will go into one direction only
  final bool reverse;

  /// [repeat]: set it to false if you don't want to repeat the animation.
  final bool repeat;

  final BorderRadiusGeometry? borderRadius;

  final double? height;

  final double? width;

  final Widget? child;

  @override
  State<OtpManagerAnimatedGradient> createState() =>
      _OtpManagerAnimatedGradientState();
}

class _OtpManagerAnimatedGradientState extends State<OtpManagerAnimatedGradient>
    with TickerProviderStateMixin {
  Animation<double>? _animation;
  AnimationController? _controller;

  late List<ColorTween> _colorTween;
  late AlignmentTween begin;
  late AlignmentTween end;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void didUpdateWidget(OtpManagerAnimatedGradient oldWidget) {
    _initialize();
    super.didUpdateWidget(oldWidget);
  }

  void _initialize() {
    _colorTween = _getColorTweens();
    if (widget.animateAlignments) _setAlignmentTweens();
    _setAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (BuildContext context, Widget? child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: widget.animateAlignments
                  ? begin.evaluate(_animation!)
                  : widget.primaryBegin,
              end: widget.animateAlignments
                  ? end.evaluate(_animation!)
                  : widget.primaryEnd,
              colors: _evaluateColors(_animation!),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  List<ColorTween> _getColorTweens() {
    if (widget.primaryColors.length != widget.secondaryColors.length) {
      throw Exception('primaryColors.length != secondaryColors.length');
    }

    final List<ColorTween> colorTweens = [];

    for (int i = 0; i < widget.primaryColors.length; i++) {
      colorTweens.add(
        ColorTween(
          begin: widget.primaryColors[i],
          end: widget.secondaryColors[i],
        ),
      );
    }

    return colorTweens;
  }

  List<Color> _evaluateColors(Animation<double> animation) {
    final List<Color> colors = [];
    for (int i = 0; i < _colorTween.length; i++) {
      colors.add(_colorTween[i].evaluate(animation)!);
    }
    return colors;
  }

  void _setAlignmentTweens() {
    final primaryBeginGeometry = widget.primaryBeginGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final primaryEndGeometry = widget.primaryEndGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final secondaryBeginGeometry = widget.secondaryBeginGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final secondaryEndGeometry = widget.secondaryEndGeometry?.resolve(
      widget.textDirectionForGeometry,
    );

    begin = AlignmentTween(
      begin: primaryBeginGeometry ?? widget.primaryBegin,
      end: primaryEndGeometry ?? widget.primaryEnd,
    );
    end = AlignmentTween(
      begin: secondaryBeginGeometry ?? widget.secondaryBegin,
      end: secondaryEndGeometry ?? widget.secondaryEnd,
    );
  }

  void _setAnimations() {
    /// Since we call [_initialize] on every state change, we need to dispose the old controller.
    /// Otherwise, it will cause a memory leak. Since every state change will create a new controller.
    if (_controller != null) _controller!.dispose();

    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _controller = AnimationController(vsync: this, duration: widget.duration);

      if (widget.repeat) {
        _controller!.repeat(reverse: widget.reverse);
      } else {
        _controller!.forward(from: 0);
      }
    }

    _animation = CurvedAnimation(parent: _controller!, curve: widget.curve);
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
