import 'package:flutter/material.dart';
import 'package:google_auth/functions/permission.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/routes/beranda/delivery_report.dart';
import 'package:google_auth/widgets/card.dart';
import 'package:google_auth/widgets/notification.dart';
import 'package:permission_handler/permission_handler.dart';

class BerandaRoute extends StatefulWidget {
  const BerandaRoute({super.key});

  @override
  State<BerandaRoute> createState() => _BerandaRouteState();
}

class _BerandaRouteState extends State<BerandaRoute> with WidgetsBindingObserver {

  late Future _checkNotification;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _checkNotification = PermissionService.checkNotification().isDenied;
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await PermissionService.checkNotification().isDenied.then((value) {
          if (value == false) {
            _checkNotification = PermissionService.checkNotification().isDenied;
          }
        }).whenComplete(() {
          if (mounted) setState(() {});
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: _checkNotification,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 4, 16),
                          child: NotificationPermissionWidget(title: 'Layanan Notifikasi Ditolak'),
                        );
                      } else { return const SizedBox(); }
                    }
                  ),
                  const ReportDeliveryWidget(),
                  const CardInvoice(),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
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
      ),
    );
  }
}
