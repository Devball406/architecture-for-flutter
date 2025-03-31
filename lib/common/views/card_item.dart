import 'package:flutter/material.dart';
import 'package:robust/common/themes/radius.dart';

class CardItem extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final Color? color;
  final RoundedRectangleBorder? shape;
  final double elevation;

  const CardItem({
    super.key,
    required this.child,
    this.margin,
    this.color,
    this.shape,
    this.elevation = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? margin = this.margin;
    RoundedRectangleBorder? shape = this.shape;
    Color? color = this.color;
    margin ??= const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0);
    shape ??= const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(circular_4r));
    color ??= Colors.white;
    return Card(
      elevation: elevation,
      shape: shape,
      color: color,
      margin: margin,
      child: child,
    );
  }
}
