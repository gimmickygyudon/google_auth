// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/widgets/chart.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';

class CreditDueWidget extends StatefulWidget {
  const CreditDueWidget({super.key});

  @override
  State<CreditDueWidget> createState() => _CreditDueWidgetState();
}

class _CreditDueWidgetState extends State<CreditDueWidget> {
  late Future<CreditDueReport> _creditDueReport;

  @override
  void initState() {
    _creditDueReport = setCreditDueReport();
    super.initState();
  }

  Future<CreditDueReport> setCreditDueReport() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    if (id_ocst != null) {
      return CreditDueReport.retrieve(id_ocst: id_ocst);
    } else {
      return Future.error('error credit due report'.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      surfaceTintColor: Colors.transparent,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5))
        ),
        child: FutureBuilder(
          future: _creditDueReport,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const HandleLoadingBar();
            } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Akumulasi Piutang', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              letterSpacing: 0,
                            )),
                            Text('Total Piutang Jatuh Tempo.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                height: 2,
                                fontSize: 10,
                                letterSpacing: 0,
                              )
                            )
                          ],
                        ),
                        ChipSmall(
                          bgColor: Theme.of(context).colorScheme.errorContainer,
                          label: '40%',
                          labelColor: Theme.of(context).colorScheme.error
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const PieChartSample3(
                          radius: 90,
                          selectedRadius: 100,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Piutang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              letterSpacing: 0,
                              color: Theme.of(context).colorScheme.secondary
                            )),
                            const SizedBox(height: 2),
                            Text('${snapshot.data?.total_balance}', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                  child: Icon(Icons.arrow_downward, size: 12, color: Theme.of(context).colorScheme.error, weight: 700, grade: 200)
                                ),
                                const SizedBox(width: 8),
                                Text('${snapshot.data?.total_balance_due}', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0,
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.error
                                )),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(1)
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Jatuh Tempo', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 10,
                                  letterSpacing: 0
                                )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(1)
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Total Piutang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 10,
                                  letterSpacing: 0
                                )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const HandleNoInternet(message: 'Tidak Terkoneksi ke Internet');
            }
          }
        )
      )
    );
  }
}