import 'package:flutter/material.dart';

import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import '../../functions/push.dart';
import '../../functions/sqlite.dart';

class DetailItemRoute extends StatefulWidget {
  const DetailItemRoute({
    super.key,
    required this.brand,
    required this.hero,
    required this.color,
    required this.item, this.type,
  });

  final String hero, brand;
  final Color color;
  final Map item;
  final String? type;

  @override
  State<DetailItemRoute> createState() => _DetailItemRouteState();
}

class _DetailItemRouteState extends State<DetailItemRoute> {
  late ScrollController _scrollController;
  bool _hideTitleSuggestion = false;
  int toolbarHeight = 0, dimensionIndex = 0;
  double expandedHeight = 300;

  String? typeNext, typePrev;
  int? typeIndexNext, typeIndexPrev;

  late List dimension, dimensions, weights;

  @override
  void initState() {
    dimension = Item.splitDimension(widget.item['OITMs'].first['spesification']);
    dimension.add(Item.defineWeight(widget.item['OITMs'].first['weight']));

    setSpesification();
    hideTitleSuggestion();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void setSpesification() {
    dimensions = List.generate(
      widget.item['OITMs'].length, (index) {
        return Item.defineDimension(widget.item['OITMs'][index]['spesification']);
      }
    );

    weights = List.generate(
      widget.item['OITMs'].length, (index) {
        return Item.defineWeight(widget.item['OITMs'][index]['weight']);
      }
    );
  }

  void hideTitleSuggestion() {
    _scrollController = ScrollController()..addListener(() {
      if (toolbarHeight <= (MediaQuery.of(context).padding.top + kToolbarHeight).round() + 50 && _hideTitleSuggestion == false) {
        setState(() {
          _hideTitleSuggestion = true;
        });
      } else if (toolbarHeight > (MediaQuery.of(context).padding.top + kToolbarHeight).round() + 50 && _hideTitleSuggestion == true) {
        setState(() {
          _hideTitleSuggestion = false;
        });
      }
    });
  }

  Future<void> addToCart({required String count, required int index}) async {
    Cart.add(
      Cart(
        id_oitm: widget.item['OITMs'][index]['id_oitm'],
        name: widget.item['description'],
        brand: widget.brand,
        dimension: Item.defineDimension(widget.item['OITMs'][index]['spesification']),
        dimensions: List.generate(
          widget.item['OITMs'].length, (i) {
            return Item.defineDimension(widget.item['OITMs'][i]['spesification']);
          }
        ),
        weight: Item.defineWeight(widget.item['OITMs'][index]['weight']),
        weights: List.generate(
          widget.item['OITMs'].length, (i) {
            return Item.defineWeight(widget.item['OITMs'][i]['weight']);
          }
        ),
        count: count
      ).toMap()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context)
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showOrderDialog(
              context: context,
              name: widget.item['description'],
              brand: widget.brand,
              hero: widget.hero,
              dimensions: dimensions,
              weights: weights,
              onPressed: addToCart
            );
          },
          icon: const Icon(Icons.local_shipping),
          label: const Text('Pesan'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.7)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Container(
          color: widget.color.withOpacity(0.05),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: expandedHeight,
                toolbarHeight: kToolbarHeight + 10,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface)),
                  icon: const Icon(Icons.arrow_back)
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 0,
                      shadowColor: Theme.of(context).shadowColor.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
                        child: Row(
                          children: [
                            Image.asset(ItemDescription.getLogo(widget.item['description']), height: 28)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CartWidget(
                        bgColor: Theme.of(context).colorScheme.surface
                      )
                    )
                  ],
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    toolbarHeight = constraints.biggest.height.round();
                    return FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _hideTitleSuggestion ? 0 : 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            typePrev != null ? TextButton.icon(
                              onPressed: () {
                                pushItemDetailPageReplace(
                                  brand: widget.brand,
                                  context: context,
                                  hero: widget.hero,
                                  color: widget.color,
                                  type: typePrev!,
                                  item: {  } // TODO: next item
                                );
                              },
                              style: ButtonStyle(
                                shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25.7),
                                    bottomRight: Radius.circular(25.7)
                                  )
                                )),
                                textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall),
                                iconSize: const MaterialStatePropertyAll(22),
                                backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background)
                              ),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(typePrev!)
                            ) : const SizedBox(),
                            typeNext != null ? TextButton.icon(
                              onPressed: () {
                                pushItemDetailPageReplace(
                                  brand: widget.brand,
                                  context: context,
                                  hero: widget.hero,
                                  color: widget.color,
                                  type: typeNext!,
                                  item: {  } // TODO: next item
                                );
                              },
                              style: ButtonStyle(
                                shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25.7),
                                    bottomLeft: Radius.circular(25.7)
                                  )
                                )),
                                textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall),
                                iconSize: const MaterialStatePropertyAll(22),
                                padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(12, 6, 8, 6)),
                                backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background)
                              ),
                              label: const Icon(Icons.arrow_forward),
                              icon: Text(typeNext!)
                            ) : const SizedBox()
                          ],
                        ),
                      ),
                      background: Container(
                        color: widget.color.withOpacity(0.05),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Hero(
                              tag: widget.hero,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(64, 80, 64, 0),
                                child: Image.asset(ItemDescription.getImage(widget.item['description'])),
                              )
                            ),
                          ]
                        ),
                      ),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      expandedTitleScale: 1,
                    );
                  }
                ),
              ),
              SliverFillRemaining(
                child: Stack(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.background,
                      child: Container(
                        color: widget.color.withOpacity(0.05),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PathTextRail(paths: [
                              'Belanja', widget.brand, widget.item['description'].toString().toTitleCase()
                            ]),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: SizedBox(
                                    height: 54,
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        ItemSpecs(
                                          value: dimension,
                                          diff: ItemDescription.getDiff(widget.item['description']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset('assets/logo IBM p C.png', height: 18),
                                          const SizedBox(width: 8),
                                          Text(widget.item['description'].toString().toTitleCase(), style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0
                                          )),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(ItemDescription.getDescription(widget.item['description']),
                                        textAlign: TextAlign.justify,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          height: 1.75
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PathTextRail extends StatelessWidget {
  const PathTextRail({super.key, required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Text.rich(
      TextSpan(
        children: paths.map((path) {
          i++;
          InlineSpan widget = TextSpan(children: [
            TextSpan(text: path, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: i == paths.length ? FontWeight.w500 : null,
              color: i == paths.length ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary.withOpacity(0.75),
              letterSpacing: 0
            )),
            if(i != paths.length) TextSpan(text: '  /  ', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outlineVariant
            ))
          ]);
        return widget;
        }).toList()
      )
    );
  }
}

class ItemSpecs extends StatelessWidget {
  ItemSpecs({super.key, required this.value, this.diff});

  final List<Map> filler = [
    {
      'name': 'Panjang',
      'icon': Icons.height,
      'type': 'mm'
    },
    {
      'name': 'Lebar',
      'icon': Icons.width_normal,
      'type': 'mm'
    },
    {
      'name': 'Tebal',
      'icon': Icons.layers,
      'type': 'mm'
    },
    {
      'name': 'Berat',
      'icon': Icons.scale,
      'type': 'kg'
    }
  ];

  final List value;
  final List? diff;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    int index = 0;
    // ignore: no_leading_underscores_for_local_identifiers
    List _value = List.from(value);

    for (var fill in filler) {
      diff?.forEach((element) {
        if (fill['name'] == element) _value[index] = "^${_value[index]}";
      });
      index++;
    }
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: filler.map((fill) {
          Widget widget = Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fill['name'].toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 1
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_value[i], style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _value[i].toString().contains('^')
                        ? Theme.of(context).colorScheme.primary
                        : null
                      )),
                      Text(" ${fill['type']}"),
                    ],
                  )
                ],
              ),
              if(i + 1 != filler.length) const VerticalDivider(width: 30)
            ],
          );
          i++;
          return widget;
        }).toList()
      ),
    );
  }
}