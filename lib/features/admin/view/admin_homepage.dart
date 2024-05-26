import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/auth.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final User? user = Auth().currentUser;
  Admin? _admin;

  Future<Admin> getAdmin(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('Admin').doc(userId).get();

    final admin = Admin.fromFirestore(doc);
    return admin;
  }

  Future<void> _getAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final admin = await getAdmin(user.uid);
    setState(() {
      _admin = admin;
    });
    print(admin.nama);
  }

  @override
  void initState() {
    super.initState();
    _getAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopBarWidget(),
          SizedBox(height: 16),
          _buildSaldoCard(),
          SizedBox(height: 16),
          _buildIconMenu(),
        ],
      ),
    );
  }

  Widget _buildIconMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                AutoRouter.of(context).push(AdminWithdrawalRoute());
              },
              child: Container(
                child: Icon(
                  IconsaxPlusLinear.card_send,
                  size: 44,
                  color: ColorValues.white,
                ),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: ColorValues.danger50,
                    borderRadius: BorderRadius.circular(100)),
              ),
            ),
            Text('Ambil', style: context.textTheme.bodySmallBold),
          ],
        ),
        Column(
          children: [
            Container(
              child: Icon(
                IconsaxPlusLinear.printer,
                size: 44,
                color: ColorValues.white,
              ),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: ColorValues.primary50,
                  borderRadius: BorderRadius.circular(100)),
            ),
            Text('Cetak', style: context.textTheme.bodySmallBold),
          ],
        ),
      ],
    );
  }

  Widget _buildSaldoCard() {
    return FutureBuilder<double>(
      future: _getTotalSaldo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final totalSaldo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(Styles.defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                  color: ColorValues.primary60,
                  borderRadius: BorderRadius.circular(Styles.defaultBorder)),
              child: Padding(
                padding: const EdgeInsets.all(Styles.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saldo',
                        style: context.textTheme.bodySmallSemiBoldBright),
                    Text('Rp $totalSaldo',
                        style: context.textTheme.titleLargeBright),
                    Padding(
                      padding: const EdgeInsets.only(top: Styles.defaultPadding),
                      child: Text("Transaksi Terakhir:", style: context.textTheme.bodySmallSemiBoldBright),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _saldoMasuk(),
                        _saldoKeluar(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<double> _getTotalSaldo() async {
    double totalSaldo = 0;
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Transaksi').get();

    snapshot.docs.forEach((doc) {
      if (doc['status'] == 'pembayaran') {
        totalSaldo += doc['saldo'];
      } else if (doc['status'] == 'pengeluaran') {
        totalSaldo -= doc['saldo'];
      }
    });

    return totalSaldo;
  }

  Future<Map<String, dynamic>> _getLastTransactions() async {
    Map<String, dynamic> lastTransactions = {
      'saldoMasuk': 0,
      'saldoKeluar': 0,
    };

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Transaksi')
        .orderBy('tanggal', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      if (doc['status'] == 'pembayaran') {
        lastTransactions['saldoMasuk'] = doc['saldo'];
      } else if (doc['status'] == 'pengeluaran') {
        lastTransactions['saldoKeluar'] = doc['saldo'];
      }
    }

    return lastTransactions;
  }

  Widget _saldoMasuk() {
    return Column(
      children: [
        Text('Saldo Masuk', style: context.textTheme.bodySmallSemiBoldBright),
        FutureBuilder<Map<String, dynamic>>(
          future: _getLastTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final lastSaldoMasuk = snapshot.data!['saldoMasuk'];
              return Text('Rp $lastSaldoMasuk',
                  style: context.textTheme.bodyMediumBoldBright);
            }
          },
        ),
      ],
    );
  }

  Widget _saldoKeluar() {
    return Column(
      children: [
        Text('Saldo Keluar', style: context.textTheme.bodySmallSemiBoldBright),
        FutureBuilder<Map<String, dynamic>>(
          future: _getLastTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final lastSaldoKeluar = snapshot.data!['saldoKeluar'];
              return Text('Rp $lastSaldoKeluar',
                  style: context.textTheme.bodyMediumBoldBright);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTopBarWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: svg.Svg('assets/Frame 6.svg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          _buildTopBarContentWidget(),
        ],
      ),
    );
  }

  Widget _buildTopBarContentWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Halo,',
                    style: context.textTheme.bodyMediumSemiBoldBright,
                  ),
                  const SizedBox(
                    height: Styles.smallSpacing,
                  ),
                  if (_admin != null)
                    Text(
                      _admin!.nama,
                      style: context.textTheme.bodyMediumBoldBright,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusBold.profile_circle,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: saldo masuk dan saldo keluar logic