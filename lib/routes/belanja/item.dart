import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/widgets/cart.dart';

import '../../styles/theme.dart';

class ItemRoute extends StatelessWidget {
  const ItemRoute({
    super.key, 
    required this.brand,
    required this.hero,
    required this.items, 
    required this.background,
    required this.color, 
    required this.logo
  });

  final List<Map> items;
  final String brand, hero, background, logo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
      ),
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                toolbarHeight: kToolbarHeight + 10,
                expandedHeight: kToolbarHeight + 100,
                automaticallyImplyLeading: false,
                forceElevated: true,
                scrolledUnderElevation: 8,
                shadowColor: color.withOpacity(0.5),
                title: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  label: Text(' Kembali', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.surface
                  )),
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.surface)
                ),
                actions: [
                  Cart(
                    icon: Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.surface
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image(image: AssetImage(logo), height: 36, width: 200, alignment: Alignment.centerLeft),
                        ],
                      ),
                    ],
                  ),
                  background: Hero(
                    tag: hero,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12),),
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: color, width: 3)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context).hoverColor,
                              Colors.black45,
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
                padding: const EdgeInsets.fromLTRB(30, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hasil Terbaru', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        letterSpacing: 0
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
                          IconButton(
                            onPressed: () {}, 
                            color: color,
                            icon: const Icon(Icons.grid_view_rounded)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(30, 0, 20, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260, mainAxisSpacing: 24, crossAxisSpacing: 24,
                    mainAxisExtent: 230
                  ),
                  delegate: SliverChildListDelegate(items.map((element) {
                    return InkWell(
                      onTap: () => pushItemDetailPage(
                        context: context,
                        brand: brand,
                        item: element,
                        hero: element['name'],
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
      ),
    );
  }
}