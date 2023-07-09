// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/text.dart';
import 'package:provider/provider.dart';
import '../../styles/theme.dart';

class AddCustomerRoute extends StatefulWidget {
  const AddCustomerRoute({super.key});

  @override
  State<AddCustomerRoute> createState() => _AddCustomerRouteState();
}

class _AddCustomerRouteState extends State<AddCustomerRoute> {
  late TextEditingController _addCustomerController;
  List<bool> selectedCustomer = List.empty(growable: true);
  List<int?> selectedCustomer_id_usr2 = List.empty(growable: true);
  final GlobalKey<State<StatefulBuilder>> floatingButtonKey = GlobalKey();
  late int defaultCustomer;


  @override
  void initState() {
    _addCustomerController = TextEditingController();
    super.initState();
  }

  void addCustomer() {
    Customer.insert(
      Customer(
        id_usr2: null,
        id_ousr: currentUser['id_ousr'].toString(),
        remarks: _addCustomerController.text.trim(),
        id_ocst: null
      )
    ).whenComplete(() => setState(() { }));
    _addCustomerController.text = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, child) => Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Tambah Pelanggan'),
                centerTitle: true,
                systemOverlayStyle: theme.darkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
                toolbarHeight: kToolbarHeight,
                collapsedHeight: kToolbarHeight,
                pinned: true,
                actions: [
                  ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
                  const SizedBox(width: 12)
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextIcon(label: 'Pelanggan', icon: Icons.factory, iconSize: 24),
                              const SizedBox(height: 2),
                              Text('Daftar pelanggan yang telah ditambahkan akan tampil disini.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  letterSpacing: 0,
                                  color: Theme.of(context).colorScheme.secondary,
                                )
                              )
                            ]
                          ),
                          const SizedBox(height: 24),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return TextField(
                                controller: _addCustomerController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                onSubmitted: _addCustomerController.text.trim().isNotEmpty
                                ? (value) => addCustomer()
                                : null,
                                decoration: Styles.inputDecorationForm(
                                  context: context,
                                  placeholder: 'Nama Pelanggan',
                                  condition: _addCustomerController.text.trim().isNotEmpty,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                    child: IconButton(
                                      onPressed: _addCustomerController.text.trim().isNotEmpty
                                      ? () => addCustomer()
                                      : null,
                                      style: Styles.buttonFlat(
                                        context: context,
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      icon: const Icon(Icons.add, size: 24),
                                    ),
                                  )
                                )
                              );
                            }
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              FutureBuilder<List?>(
                future: Customer.retrieve(id_ousr: currentUser['id_ousr']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: HandleLoading())
                    );
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    List<Customer>? customers = snapshot.data?.reversed.toList() as List<Customer>;
                    selectedCustomer = List.filled(customers.length, false);
                    selectedCustomer_id_usr2 = List.empty(growable: true);

                    for (var i = 0; i < customers.length; i++) {
                      selectedCustomer_id_usr2.add(customers[i].id_usr2);
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      sliver: SliverList.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return ValueListenableBuilder(
                                    valueListenable: Customer.defaultCustomer,
                                    builder: (context, customer, child) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ListTile(
                                          onTap: () {
                                            setState(() {
                                              if (selectedCustomer[index] == true) {
                                                selectedCustomer[index] = false;
                                              } else {
                                                selectedCustomer[index] = true;
                                              }
                                            });
                                            floatingButtonKey.currentState?.setState(() {});
                                          },
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12)
                                            )
                                          ),
                                          tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                          selected: selectedCustomer[index] == true,
                                          selectedColor: Theme.of(context).colorScheme.surface,
                                          selectedTileColor: Theme.of(context).colorScheme.surfaceTint,
                                          minVerticalPadding: 12,
                                          title: Text(customers[index].remarks),
                                          titleTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            height: 1.8
                                          ),
                                          subtitle: Text('#${customers[index].id_usr2.toString()}'),
                                          subtitleTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary
                                          ),
                                          isThreeLine: true,
                                          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                          leading: Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Badge(
                                              backgroundColor: Colors.transparent,
                                              label: selectedCustomer[index] == true
                                              ? Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(25.7),
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                child: Icon(Icons.check, color: Theme.of(context).colorScheme.surface, size: 14)
                                              )
                                              : null,
                                              largeSize: 22,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: selectedCustomer[index] == true
                                                  ? Theme.of(context).colorScheme.onInverseSurface
                                                  : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                                                  shape: BoxShape.circle
                                                ),
                                                child: Text(customers[index].remarks.substring(0, 1).toUpperCase(), style: Theme.of(context).textTheme.bodyMedium),
                                              ),
                                            ),
                                          ),
                                          trailing: customers[index].id_usr2 == customer?.id_usr2
                                          ? ChipSmall(
                                            bgColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(selectedCustomer[index] == true ? 1.0 : 0.5),
                                            label: 'Digunakan',
                                            labelColor: Theme.of(context).colorScheme.primary,
                                            trailing: Icon(Icons.query_stats, color: Theme.of(context).colorScheme.primary, size: 16),
                                          )
                                          : null,
                                        ),
                                      );
                                    }
                                  );
                                }
                              )
                            ],
                          ),
                        );
                      }),
                    );
                  } else {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                },
              )
            ],
          ),
          floatingActionButton: StatefulBuilder(
            key: floatingButtonKey,
            builder: (context, setStateWidget) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                offset: Offset(0, selectedCustomer.contains(true) ? 0 : 6),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      List<int?> customer = List.empty(growable: true);

                      for (int i = 0; i < selectedCustomer.length - 1; i++) {
                        if (selectedCustomer[i] == true) {
                          customer.add(selectedCustomer_id_usr2[i]);
                          selectedCustomer[i] = false;
                        }
                      }

                      Customer.remove(id_usr2: customer.join(','));
                    });
                  },
                  style: Styles.buttonFlat(
                    context: context,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    overlayColor: Theme.of(context).colorScheme.onErrorContainer
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus')
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
