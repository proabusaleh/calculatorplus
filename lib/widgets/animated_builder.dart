import 'package:flutter/material.dart';

class AppAnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AppAnimatedBuilder({
    super.key,
    required Listenable animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
