import 'package:flutter/material.dart';

class PhotoProfile extends StatelessWidget {
  const PhotoProfile({super.key, this.photo, this.size, this.color});

  final String? photo;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget widget = photo != null 
    ? CircleAvatar(backgroundImage: NetworkImage(photo!)) 
    : Icon(Icons.account_circle, size: size, color: color);
    return widget;
  }
}