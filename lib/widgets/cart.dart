import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key, this.color, this.bgColor, this.icon});

  final Color? color;
  final Color? bgColor;
  final IconData? icon;

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {

  final GlobalKey<State<StatefulBuilder>> cartListkey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void removeItem(int index) {
    Cart.remove(index: index).whenComplete(() => cartListkey.currentState?.setState(() {}));
  }

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
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      )),
                      visualDensity: VisualDensity.compact,
                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                      iconSize: const MaterialStatePropertyAll(18),
                      textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0
                      ))
                    ),
                    label: const Text('Lokasi'),
                    icon: const Icon(Icons.near_me_outlined)
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
      ] + [
        PopupMenuItem(
          child: StatefulBuilder(
            key: cartListkey,
            builder: (context, setState) {
              return FutureBuilder(
                future: Cart.getItems(),
                builder: (context, snapshot) {
                  return AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400, minHeight: 0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length ?? 0,  
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: CartListWidget(
                                index: index,
                                onDelete: removeItem,
                                item: snapshot.data?[index],
                              ),
                            );
                          },
                      ),
                    ),
                  );
                },
              );
            }
          )
        ),
        PopupMenuItem(
          height: 0,  
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          )
        ),
        PopupMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Cart.removeAll().whenComplete(() {
                      cartListkey.currentState?.setState(() {});
                    });
                  },
                  style: ButtonStyle(
                    iconSize: const MaterialStatePropertyAll(18),
                    textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600
                    )),
                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
                    overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error.withOpacity(0.25))
                  ),
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('Hapus Daftar')
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )),
                    elevation: const MaterialStatePropertyAll(0),
                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
                    backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColorDark),
                    overlayColor: MaterialStatePropertyAll(Theme.of(context).primaryColorLight)
                  ),
                  icon: const Icon(Icons.playlist_add, size: 26),
                  label: const Text('Buat Pesanan')
                ),
              ],
            ),
          )
        )
      ],
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

class CartListWidget extends StatelessWidget {
  const CartListWidget({
    super.key,
    required this.index, 
    required this.item, 
    required this.onDelete
  });

  final int index;
  final Map? item;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {

    // TODO: may error in future
    List<String> spesifications = List.generate(item?['dimensions'].length, (index) {
      return '${item?['dimensions'][index] + '  •  ' + item?['weights'][index]} Kg';
    });
    String spesification = spesifications.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8, right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColorLight.withOpacity(0.5)
                    ),
                    child: Stack(
                      children: [
                        Image.asset(ItemDescription.getImage(item?['name']), width: 60, fit: BoxFit.cover),
                      ],
                    )
                  ),
                  Positioned.fill(
                    right: 12,
                    bottom: 6,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Badge.count(
                        count: 3,
                        largeSize: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      )
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 
                        Row(
                          children: [
                            Text('${item?['name'].toString().toTitleCase()}', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              height: 0
                            )),
                            Text(' #00${index + 1}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary
                            ))
                          ],
                        ),
                        Text(item?['brand'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      ],
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(10),
                      value: spesification,
                      onChanged: (value) {
                        spesification = value!;
                      },
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        height: 0
                      ),
                      items: spesifications.map<DropdownMenuItem<String>>((element) {
                        return DropdownMenuItem<String>(
                          value: element,
                          child: Text(element)
                        );
                      }).toList()
                    ),
                  )
                ],
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => onDelete(index),
                style: ButtonStyle(
                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  textStyle: MaterialStatePropertyAll(
                    Theme.of(context).textTheme.labelSmall
                  ),
                  foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
                ),
                icon: const Icon(Icons.cancel)
              ),
            ],
          )
        ]
      ),
    );
  }
}