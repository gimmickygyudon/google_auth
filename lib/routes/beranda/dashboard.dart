import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';

import '../../strings/user.dart';

class BerandaRoute extends StatefulWidget {
  const BerandaRoute({super.key});

  @override
  State<BerandaRoute> createState() => _BerandaRouteState();
}

class _BerandaRouteState extends State<BerandaRoute> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhysicalModel(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          shadowColor: Theme.of(context).colorScheme.inversePrimary,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 8)),
                              color: Theme.of(context).colorScheme.primary
                            ),
                            child: Column(
                              children: [
                                Text.rich(
                                  TextSpan( 
                                    children: [
                                      TextSpan(text: 'Rp', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
                                      TextSpan(text: '12.000', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.surface
                                      )),
                                      const WidgetSpan(child: SizedBox(width: 8)),
                                      WidgetSpan(child: Icon(Icons.trending_up, color: Theme.of(context).colorScheme.surface)),
                                    ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sync, size: 12),
                            const SizedBox(width: 4,),
                            Text('Update setiap hari ${DateNow()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                letterSpacing: 0
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: Card(
                    color: Theme.of(context).hoverColor,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1, 
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.05)
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Perolehan Kamu', style: Theme.of(context).textTheme.titleSmall),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children: const [
                                    IconButtonText(icon: Icons.scale, label: 'Jumlah', value: '0 Ton'),
                                    SizedBox(width: 10),
                                    IconButtonText(icon: Icons.card_giftcard, label: 'Piutang', value: 'Rp. 0'),
                                    SizedBox(width: 10),
                                    IconButtonText(icon: Icons.local_shipping, label: 'Antrean', value: '150'),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: ButtonStyle(
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 6)),
                                  textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.25)),
                                  iconSize: const MaterialStatePropertyAll(16)
                                ),
                                onPressed: () {}, 
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Rincian Pencapaian'),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => pushAddCustomer(context),
                          splashColor: Theme.of(context).colorScheme.inversePrimary,
                          highlightColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary)
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tambah\nPelanggan', 
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        height: 1.25,
                                        letterSpacing: 0
                                      )
                                    ),
                                    const SizedBox(width: 24),
                                    Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('0', 
                                      textAlign: TextAlign.end, 
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        height: 1.25
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ]
    );
  }
}

// TODO: MOVE THIS SOMEWHERE LATER

class IconButtonText extends StatelessWidget {
  const IconButtonText({super.key, required this.label, this.value, required this.icon});

  final String label;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary)
            ),
            const SizedBox(height: 12),
            if(value != null) Text(value!, style: Theme.of(context).textTheme.labelMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10
              )
            )
          ],
        ),
      ),
    );
  }
}

