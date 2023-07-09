import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/routes/beranda/delivery_report.dart';
import 'package:google_auth/styles/theme.dart';

class CreditDueDetailReport extends StatefulWidget {
  const CreditDueDetailReport({super.key});

  @override
  State<CreditDueDetailReport> createState() => _CreditDueDetailReportState();
}

class _CreditDueDetailReportState extends State<CreditDueDetailReport> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Piutang'),
          titleSpacing: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: CustomerSelectWidget(onChanged: () {
                // setDeliveryOrder();
              }),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: CreditDueReport.description(context)[0]['color'].withOpacity(0.1),
                        child: Icon(size: 18, Icons.arrow_downward, color: CreditDueReport.description(context)[0]['color'].withRed(150))
                      ),
                      const SizedBox(width: 6),
                      Text('Jatuh Tempo', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: CreditDueReport.description(context)[0]['color'].withRed(150),
                        letterSpacing: 0
                      )),
                    ],
                  ),
                  Text('Total Piutang', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CreditDueReport.description(context)[1]['color'],
                    letterSpacing: 0
                  ))
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rp10.0 Jt', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CreditDueReport.description(context)[0]['color'].withRed(150),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0
                  )),
                  Text('Rp40.0 Jt', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CreditDueReport.description(context)[1]['color'],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0
                  ))
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
                minHeight: 10,
                valueColor: AlwaysStoppedAnimation<Color>(CreditDueReport.description(context)[0]['color']),
                value: 0.4,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('20.0%', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CreditDueReport.description(context)[0]['color'],
                    letterSpacing: 0
                  )),
                  Text('80.0%', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CreditDueReport.description(context)[1]['color'],
                    letterSpacing: 0
                  ))
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}