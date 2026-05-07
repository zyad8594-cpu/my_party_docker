import 'package:flutter/material.dart';

class MyPScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const MyPScrollbar({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Move scrollbar to right
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: Directionality(
          textDirection: TextDirection.rtl, // Keep content RTL
          child: child,
        ),
      ),
    );
  }
}
