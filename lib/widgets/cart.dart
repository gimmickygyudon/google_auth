import 'package:flutter/material.dart';
import 'package:google_auth/strings/user.dart';

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
      padding: EdgeInsets.zero,
      elevation: 8,
      shadowColor: Theme.of(context).splashColor,
      surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
      constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined),
                      SizedBox(width: 6),
                      Text('Belanja')
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      visualDensity: VisualDensity.compact,
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ))
                    ),
                    label: const Text('Lokasi'),
                    icon: const Icon(Icons.near_me)
                  )
                ],
              ),
              Text.rich(TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 0,
                  color: Theme.of(context).colorScheme.secondary
                ),
                children: [
                  TextSpan(text: DateNow())
                ]
              )),
            ],
          )
        ),
        const PopupMenuItem(
          height: 0,  
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 6),
            child: PopupMenuDivider(),
          )
        ),
      ] + List.generate(3, (index) {
        return PopupMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).primaryColorLight.withOpacity(0.5)
                      ),
                      child: const FlutterLogo(size: 64)
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Produk #008$index'),
                            Text('Indostar', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              height: 0
                            )),
                          ],
                        ),
                        DropdownButton(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(10),
                          value: '2400 x 200 x 8 (5.5 kg)',
                          onChanged: (value) {},
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            height: 0
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '2400 x 200 x 8 (5.5 kg)',
                              child: Text('2400 x 200 x 8 (5.5 kg)')
                            )
                          ]
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        textStyle: MaterialStatePropertyAll(
                          Theme.of(context).textTheme.labelSmall
                        ),
                        foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
                      ),
                      child: const Text('Cancel')
                    ),
                    const SizedBox(height: 12),
                    DropdownButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(10),
                      value: '2 Qt',
                      onChanged: (value) {},
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        height: 0
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '2 Qt',
                          child: Text('2 Qt')
                        )
                      ]
                    )
                  ],
                )
              ]
            ),
          )
        );
      }),
      child: CircleAvatar(
        backgroundColor: widget.bgColor ?? Colors.transparent,
        child: Icon(
          widget.icon ?? Icons.local_shipping_outlined,
          color: widget.color,
        ),
      ),
    );
  }
}