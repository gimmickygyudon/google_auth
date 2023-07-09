// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/functions/push.dart';
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
      return CreditDueReport.retrieve(id_ocst: id_ocst).then((value) {
        return value;
      });
    } else {
      return CreditDueReport(total_balance: 'Rp60.0 Jt', total_balance_due: 'Rp20.0 Jt', percent_balance: 67, percent_balance_due: 33);
      // return Future.error('error credit due report'.toUpperCase());
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
              return const SizedBox();
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
                          leading: Icon(Icons.trending_down, size: 18, color: Theme.of(context).colorScheme.surface),
                          bgColor: CreditDueReport.description(context)[0]['color'],
                          label: '${snapshot.data?.percent_balance_due}%',
                          labelColor: Theme.of(context).colorScheme.surface
                        )
                      ],
                    ),
                    Row(
                      children: [
                        CreditDueChart(
                          radius: 90,
                          selectedRadius: 100,
                          creditDueReport: snapshot.data,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Piutang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                  backgroundColor: CreditDueReport.description(context)[0]['color'],
                                  child: Icon(Icons.arrow_downward, size: 12, color: Theme.of(context).colorScheme.surface, weight: 700, grade: 200)
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
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: CreditDueReport.description(context)[1]['color'],
                                    borderRadius: BorderRadius.circular(2)
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
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: CreditDueReport.description(context)[0]['color'],
                                    borderRadius: BorderRadius.circular(2)
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
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          style: ButtonStyle(
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 6)),
                            textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0)),
                            iconSize: const MaterialStatePropertyAll(16)
                          ),
                          onPressed: () => pushCreditDetailReport(context: context, onPop: () => setState(() {})),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rincian Piutang'),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const HandleNoData();
            }
          }
        )
      )
    );
  }
}