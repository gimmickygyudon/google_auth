import 'package:flutter/material.dart';

import '../functions/color.dart';
import '../functions/customer.dart';
import '../functions/push.dart';
import '../strings/user.dart';

class DropdownLight extends StatelessWidget {
  const DropdownLight({super.key, required this.value, required this.values, required this.onChanged});

  final String? value;
  final List<String> values;
  final Function(dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 4, 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6)
      ),
      child: DropdownButton(
        isDense: true,
        underline: const SizedBox(),
        value: value,
        borderRadius: BorderRadius.circular(8),
        onChanged: (value) => onChanged(value),
        elevation: 0,
        dropdownColor: lighten(Theme.of(context).colorScheme.primaryContainer, 0.05),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0
        ),
        iconEnabledColor: Theme.of(context).colorScheme.primary,
        items: values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e)
          );
        }).toList()
      ),
    );
  }
}

class DropdownCustomerSelect extends StatefulWidget {
  const DropdownCustomerSelect({super.key, this.onChanged});

  final Function? onChanged;

  @override
  State<DropdownCustomerSelect> createState() => _DropdownCustomerSelectState();
}

class _DropdownCustomerSelectState extends State<DropdownCustomerSelect> {
  late Future<List<Customer?>> _getCustomer;

  @override
  void initState() {
    _getCustomer = Customer.retrieve(id_ousr: currentUser['id_ousr']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCustomer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 160,
            height: 40,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(25.7),
            ),
            child: const LinearProgressIndicator(backgroundColor: Colors.transparent)
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Container(
            height: 40,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(25.7),
            ),
            child: ValueListenableBuilder(
              valueListenable: Customer.defaultCustomer,
              builder: (context, customer, child) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<Customer?>(
                    value: customer,
                    onChanged: (Customer? value) {
                      setState(() {
                        Customer.setDefaultCustomer(value);
                        if (widget.onChanged != null) widget.onChanged!();
                      });
                    },
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(25.7),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface
                    ),
                    dropdownColor: Theme.of(context).colorScheme.primary,
                    iconEnabledColor: Theme.of(context).colorScheme.surface,
                    items: snapshot.data?.map<DropdownMenuItem<Customer>>((Customer? customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: Theme.of(context).colorScheme.background,
                              child: Text(customer!.remarks.substring(0, 1).toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600
                              ))
                            ),
                            const SizedBox(width: 8),
                            Text(customer.remarks),
                          ],
                        )
                      );
                    }).toList(),
                  ),
                );
              }
            ),
          );
        } else {
          return OutlinedButton.icon(
            onPressed: () => pushAddCustomer(context),
            style: ButtonStyle(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
              side: const MaterialStatePropertyAll(
                BorderSide(color: Colors.transparent, width: 0)
              ),
              backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),
              minimumSize: const MaterialStatePropertyAll(Size(160, 40)),
              iconSize: const MaterialStatePropertyAll(20),
              textStyle: MaterialStatePropertyAll(
                Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0
                )
              )
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Tambah Pelanggan')
          );
        }
      },
    );
  }
}