import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/payments.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/radio.dart';

Future<void> showPaymentSheet(BuildContext context, Function(int indexPaymentsType) onConfirm) {
  AsyncMemoizer<List<String>> paymentsMemoizer = AsyncMemoizer();

  List<Map> payments = [
    {
      'name': 'COD',
      'icon': Icons.payment
    }, {
      'name': 'CASH',
      'icon': Icons.money
    }, {
      'name': 'BANK',
      'icon': Icons.local_atm
    }
  ];

  String? selected;
  int selectedIndex = 1;
  Future<List<String>> getPayments() {
    return paymentsMemoizer.runOnce(() {
      return Payment.getPaymentType().then((value) {
        for (var i = 0; i < value.length; i++) {
          payments[i]['name'] = value[i].toTitleCase();
        }

        selected = value.first.toTitleCase();
        return value;
      });
    });
  }

  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    barrierColor: Colors.black38,
    builder: (context) {
    return FutureBuilder(
      future: getPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Wrap(
            children: [
              Center(child: HandleLoading()),
              SizedBox(height: 200)
            ],
          );
        } else if (snapshot.hasError) {
          return const HandleNoInternet(message: 'Periksa Koneksi Internet Anda');
        }
        return StatefulBuilder(
          builder: (context, setState) {
            void setPayment(String payment, int index) {
              setState(() {
                selected = payment;
                selectedIndex = index;
              });
            }
            return Padding(
              padding: const EdgeInsets.all(0),
              child: Wrap(
                children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Text('Pembayaran', style: Theme.of(context).textTheme.titleLarge),
                        Text('Pilih Metode Pembayaran', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary
                        )),
                        const SizedBox(height: 24)
                      ],
                    )
                  ),
                  for (var i = 0; i < payments.length; i++)
                  PaymentRadioList(
                    index: i + 1,
                    payments: payments,
                    payment: payments[i],
                    selected: selected,
                    onChanged: setPayment
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: Text('Tutup', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary
                          )),
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.secondary),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            onConfirm(selectedIndex);
                          },
                          style: Styles.buttonFlat(context: context),
                          child: const Text('Pesan Sekarang')
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  });
}