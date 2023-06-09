import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/info.dart';
import 'package:google_auth/widgets/profile.dart';

import '../../functions/payments.dart';

class PaymentRoute extends StatefulWidget {
  const PaymentRoute({super.key, required this.delivertype, required this.onConfirm});

  final String? delivertype;
  final Future Function(int indexPaymentsType) onConfirm;

  @override
  State<PaymentRoute> createState() => _PaymentRouteState();
}

class _PaymentRouteState extends State<PaymentRoute> {

  AsyncMemoizer<List<String>> paymentsMemoizer = AsyncMemoizer();
  late Future _getPayment;
  late bool isLoading, noInternet;
  int? selectedIndex;

  @override
  void initState() {
    isLoading = false;
    noInternet = true;
    _getPayment = getPayments();
    super.initState();
  }

  Future<List<String>> getPayments() {
    return paymentsMemoizer.runOnce(() {
      return Payment.getPaymentType().then((value) {
        for (var i = 0; i < value.length; i++) {
          Payment.payments[i]['name'] = value[i].toTitleCase();
        }

        setState(() => noInternet = false);
        return value;
      }).onError((error, stackTrace) {
        setState(() => noInternet = true);
        return Future.error(error.toString());
      });
    });
  }

  void selectPayment(index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
        actions: [
          ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
          const SizedBox(width: 8)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: selectedIndex != null ? 0 : null,
              child: Visibility(
                visible: selectedIndex != null ? false : true,
                child: const InfoSmallWidget(
                  message: 'Pilih metode pembayaran yang akan digunakan.',
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: _getPayment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: HandleLoading());
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30
                      ),
                      itemBuilder: (context, index) {
                        return PaymentCard(
                          onTap: selectPayment,
                          index: index,
                          isSelected: selectedIndex == index,
                          item: snapshot.data!,
                          isLoading: isLoading,
                          iconSize: 40,
                        );
                      }
                    );
                  } else {
                    return const Center(
                      child: HandleNoInternet(message: 'Tidak tersambung ke Internet')
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        curve: Curves.ease,
        duration: const Duration(milliseconds: 400),
        offset: Offset(0, noInternet || selectedIndex == null ? 2 : 0),
        child: FloatingActionButton.extended(
          onPressed: noInternet || selectedIndex == null ? null : () {
            setState(() => isLoading = true);
            widget.onConfirm(selectedIndex!).whenComplete(() => setState(() => isLoading = false));
          },
          elevation: isLoading ? 0 : 4,
          backgroundColor: isLoading ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5) : Theme.of(context).colorScheme.primary,
          foregroundColor: isLoading ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          extendedPadding: const EdgeInsets.all(24),
          icon: isLoading
          ? const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
              ),
          )
          : const Icon(Icons.done_all),
          label: isLoading
          ? const Text('Memproses Pesanan...')
          : const Text('Checkout')
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.item,
    this.iconSize,
    this.bgRadius,
    this.isSelected,
    this.color,
    this.bgColor, required this.index, this.onTap, this.isLoading
  });

  final int index;
  final bool? isSelected, isLoading;
  final List<String> item;
  final double? iconSize, bgRadius;
  final Color? color, bgColor;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      scale: isSelected == true ? 1.1 : 1,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            onTap: onTap != null && isLoading == false ? () {
              if (onTap != null) onTap!(index);
            } : null,
            splashColor: isSelected == true
              ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05)
              : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            highlightColor: isSelected == true
              ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05)
              : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(isSelected == true ? 1 : 0.05),
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  end: Alignment.bottomCenter,
                  begin: Alignment.topCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    Theme.of(context).colorScheme.primary
                  ]
                ),
                border: Border.all(
                  width: isSelected == true ? 0 : 2,
                  color: isSelected == true
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.primary.withOpacity(0.25)
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: bgColor,
                        radius: bgRadius,
                        child: Icon(Payment.payments[index]['icon'],
                          size: iconSize ?? 24,
                          color: color ?? Theme.of(context).colorScheme.primary
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(Payment.payments[index]['name'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected == true ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary,
                          height: 1.25,
                          letterSpacing: 0
                        )
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isSelected == null) Icon(Icons.arrow_forward, size: 24, color: Theme.of(context).colorScheme.primary),
                      if (isSelected == true) ...[
                        Icon(Icons.check_circle,
                          size: 24,
                          color: isSelected == true ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary
                        )
                      ]
                    ],
                  ),
                ],
              ),
          ),
        )
      ),
    );
  }
}
