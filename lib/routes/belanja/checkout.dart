import 'package:flutter/material.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/profile.dart';

class CheckoutRoute extends StatefulWidget {
  const CheckoutRoute({super.key});

  @override
  State<CheckoutRoute> createState() => _CheckoutRouteState();
}

class _CheckoutRouteState extends State<CheckoutRoute>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            titleSpacing: 0,
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Orders: ', style: Theme.of(context).textTheme.labelLarge),
                  TextSpan(text: '0001/VI/23', style: Theme.of(context).textTheme.bodyMedium)
                ]
              )
            ),
            actions: [
              ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
              const SizedBox(width: 12)
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(child: Text('Barang')),
                Tab(child: Text('Tujuan')),
                Tab(child: Text('Pengiriman'))
              ]
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            ItemPage(),
            Placeholder(),
            Placeholder()
          ]
        )
      )
    );
  }
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {},
          style: Styles.buttonFlatSmall(context: context),
          child: const Text('Invoice')
        ),
        const SizedBox(width: 1),
      ],
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
            sliver: SliverList.builder(
              itemBuilder: (context, index) {
                return ListTileTheme(
                  minVerticalPadding: 14,
                  child: ListTile(
                    leading: AspectRatio(
                      aspectRatio: 4/3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Image.asset('assets/Indostar Bes.png')
                      ),
                    ),
                    title: Text('Indostarbes', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    )),
                    subtitle: Text('Indostar', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary
                    )),
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}