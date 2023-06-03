import 'package:flutter/material.dart';

import 'package:google_auth/functions/push.dart';
import 'package:google_auth/widgets/image.dart';
import '../../functions/authentication.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Card(
                              color: Theme.of(context).hoverColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(text: 'Rp', style: const TextStyle(fontSize: 11), children: [                                          
                                        TextSpan(text: '12.000', style: Theme.of(context).textTheme.titleSmall),
                                      ]),
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Update setiap hari $DateNow', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 10
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 190,
                          child: Card(
                            color: Theme.of(context).hoverColor,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Perolehan Kamu', style: Theme.of(context).textTheme.titleSmall),
                                  Expanded(
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
                                  TextButton.icon(
                                    style: const ButtonStyle(
                                      visualDensity: VisualDensity(horizontal: -4, vertical: -4)
                                    ),
                                    onPressed: () {}, 
                                    icon: const Text('Rincian'),
                                    label: const Icon(Icons.navigate_next),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: const [
                        IconButtonText(icon: Icons.person_add, label: 'Tambah Pelanggan')
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}

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
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
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

