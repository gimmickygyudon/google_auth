import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';

import '../../styles/theme.dart';

class ItemRoute extends StatelessWidget {
  const ItemRoute({
    super.key, 
    required this.hero,
    required this.items, 
    required this.background,
    required this.color, required this.logo
  });

  final List<Map> items;
  final String hero, background, logo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: kToolbarHeight + 10,
              title: Row(
                children: [
                  Image(image: AssetImage(logo), height: 26),
                ],
              ),
              titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.surface
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  icon: const Icon(Icons.shopping_cart_outlined)
                ),
                const SizedBox(width: 12)
              ],
              forceElevated: true,
              scrolledUnderElevation: 8,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.5),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.surface)
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: hero,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12),),
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black45,
                            Theme.of(context).hoverColor,
                          ]
                        )
                      ),
                      child: Image.asset(background, 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hasil Terbaru'),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: 'Tipe',
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 0,
                          color: Theme.of(context).colorScheme.primary
                        ),
                        items: const [ 
                          DropdownMenuItem(
                            value: 'Tipe',
                            child: Text('Tipe')
                          ) 
                        ], 
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, mainAxisSpacing: 24, crossAxisSpacing: 24,
                  mainAxisExtent: 200
                ),
                delegate: SliverChildListDelegate(items.map((element) {
                  return InkWell(
                    onTap: () => pushItemDetailPage(
                      context: context, 
                      items: items,
                      itemImage: element['img'], 
                      hero: hero,
                      color: color
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(spreadRadius: -4, blurRadius: 8, offset: const Offset(0, 4), color: Theme.of(context).shadowColor.withOpacity(0.15))
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: PhysicalModel(
                                color: Colors.transparent,
                                elevation: 8,
                                borderRadius: BorderRadius.circular(20),
                                shadowColor: color.withOpacity(0.25),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Hero(
                                    tag: element['name'],
                                    child: Image.asset(element['img'], fit: BoxFit.contain)
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 0,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            title: Text(element['name']),
                            titleTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              height: 1.75,
                              letterSpacing: 0
                            ),
                            subtitle: Row(
                              children: [
                                Text('5.5 Kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary
                                )),
                              ],
                            ),
                          ),
                          const Divider(indent: 12, endIndent: 12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Row(
                              children: [
                                Icon(Icons.square_foot, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 2),
                                Text('2400 x 200 x 8', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  height: 0
                                ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList()), 
              ),
            )
          ]
        ),
      ),
    );
  }
}