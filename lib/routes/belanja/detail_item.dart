import 'package:flutter/material.dart';

class DetailItemRoute extends StatefulWidget {
  const DetailItemRoute({
    super.key, 
    required this.itemImage, 
    required this.hero, 
    required this.color,
    required this.items
  });

  final String itemImage;
  final String hero;
  final Color color;
  final List<Map> items;

  @override
  State<DetailItemRoute> createState() => _DetailItemRouteState();
}

class _DetailItemRouteState extends State<DetailItemRoute> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 300,
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
                      Image.asset('assets/Logo IndostarBes.png', width: 200)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.surface
                    )
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined)
                ),
              )
            ],
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: widget.color.withOpacity(0.05),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Expanded(
                    child: Hero(
                      tag: widget.hero,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(64, 80, 64, 0),
                        child: Image.asset(widget.itemImage),
                      )
                    ),
                  ),
                ]
              ),
            ),
            titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            expandedTitleScale: 1,
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
                      const PathTextRail(paths: [
                        'Belanja', 'Indostar', 'Indostarbes'
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: ItemSpecs(value: const ['2400', '200', '8', '5.5']),
                            ),
                            Row(
                              children: [
                                Image.asset('assets/logo IBM p C.png', height: 18),
                                const SizedBox(width: 8),
                                Text(widget.items.first['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0
                                )),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Indostar Plank cocok digunakan sebagai list plank maupun sidding plank untuk rumah dengan konsep klasik dan berseni.', 
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
                ),
              ),
            ],
          ),
        )
      ],
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
  ItemSpecs({super.key, required this.value});

  final List value;
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

  @override
  Widget build(BuildContext context) {
    int i = 0;
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
                      Text(value[i], style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500
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