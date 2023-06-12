import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({super.key, this.color, this.bgColor, this.icon});

  final Color? color;
  final Color? bgColor;
  final IconData? icon;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          child: Text('List Penyimpanan')
        )
      ],
      child: CircleAvatar(
        backgroundColor: widget.bgColor ?? Colors.transparent,
        child: Icon(
          widget.icon ?? Icons.shopping_cart_outlined,
          color: widget.color,
        ),
      ),
    );
  }
}