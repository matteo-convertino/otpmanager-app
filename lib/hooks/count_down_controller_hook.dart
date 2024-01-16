import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

CountDownController useCountDownController() {
  final controller = useMemoized(CountDownController.new, []);
  return controller;
}