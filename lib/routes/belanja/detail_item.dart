import 'package:flutter/material.dart';

import '../../styles/theme.dart';

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
          expandedHeight: 300,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface)
            ),
            icon: const Icon(Icons.arrow_back)
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: widget.color.withOpacity(0.05),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Hero(
                      tag: widget.hero,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 64, 32, 0),
                        child: Image.asset(widget.itemImage),
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: List.generate(3, (index) {
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).hoverColor,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FlutterLogo(size: 60),
                          ),
                        );
                      }),
                    ),
                  )
                ]
              ),
            ),
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
                      // TODO: add route path to here with pads (Text.rich)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/logo IBM p C.png', height: 22),
                              const SizedBox(width: 12),
                              Text(widget.items.first['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              )),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            icon: const Icon(Icons.grade_outlined, color: Colors.orange)
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Indostarboard Plank mempunyai enam macam ukuran'),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: widget.color.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.square_foot, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 2),
                            Text('2400 x 200 x 8', style: Theme.of(context).textTheme.bodyMedium?.copyWith()),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Text('5.5 Kg', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // TODO: fill this column
                      Text('Info Produk', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      )),
                      Text('Indostar Plank cocok digunakan sebagai list plank maupun sidding plank untuk rumah dengan konsep klasik dan berseni.')
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