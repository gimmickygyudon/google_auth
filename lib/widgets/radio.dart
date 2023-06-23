import 'package:flutter/material.dart';

class PaymentRadioList extends StatefulWidget {
  const PaymentRadioList({super.key, required this.payment, required this.selected, required this.onChanged, required this.payments});

  final List payments;
  final Map payment;
  final String? selected;
  final Function onChanged;

  @override
  State<PaymentRadioList> createState() => _PaymentRadioListState();
}

class _PaymentRadioListState extends State<PaymentRadioList> {
  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      selected: widget.payment['name'] == widget.selected,
      value: widget.payment['name'],
      groupValue: widget.selected,
      onChanged: (value) {
        widget.onChanged(value);
      },
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(widget.payment['name'], style: Theme.of(context).textTheme.labelLarge),
      selectedTileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
      secondary: Icon(widget.payment['icon']),
    );
  }
}