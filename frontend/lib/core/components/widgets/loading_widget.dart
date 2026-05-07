import 'package:flutter/material.dart' show
  StatelessWidget, Widget, BuildContext, Brightness, 
  Theme, CircularProgressIndicator, Center, Color, SizedBox;
import '../../themes/app_colors.dart';


class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingWidget({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    Widget indicator = CircularProgressIndicator(
      color: color ?? AppColors.primary.getByBrightness(brightness),
      strokeWidth: 3,
    );
    
    if (size != null) {
      indicator = SizedBox(width: size, height: size, child: indicator);
    }

    return Center(
      child: indicator,
    );
  }
}