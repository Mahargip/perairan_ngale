import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/database/db_constants.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Customer? _customer;
  Future<Customer> getCustomer(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Customer')
        .doc(userId)
        .get();

    final customer = Customer.fromFirestore(doc);
    return customer;
  }

  Future<void> _getCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final customer = await getCustomer(user.uid);
    setState(() {
      _customer = customer;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBarWidget(),
            _buildRecordsWidget(),
          ],
        ),
      ),
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
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusLinear.profile_circle,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_customer != null)
                      Text(
                        _customer!.nama,
                        style: context.textTheme.bodyMediumBoldBright,
                      ),
                    const SizedBox(
                      height: Styles.smallSpacing,
                    ),
                    if (_customer != null)
                      Text(
                        _customer!.customerNo,
                        style: context.textTheme.bodySmallBright,
                      ),
                  ]),
            ),
            IconButton(
              icon: const Icon(
                IconsaxPlusLinear.setting,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
              onPressed: () {
                AutoRouter.of(context)
                    .push(CustomerProfileRoute(customer: _customer!));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: ColorValues.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            Center(
              child: Text(
                "Riwayat Pencatatan",
                style: context.textTheme.bodyMediumBold,
              ),
            ),
            _buildHistoryWidget(),
            _buildHistoryWidget(),
            _buildHistoryWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryWidget() {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(CustomerRecordDetailRoute());
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Styles.smallerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Mei 2024",
                  style: context.textTheme.bodyMediumBold,
                ),
              ),
              _buildHistoryItemWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItemWidget() {
    return Container(
      decoration: BoxDecoration(
        color: ColorValues.white,
        borderRadius: BorderRadius.circular(Styles.defaultBorder),
        border: Border.all(
          color: ColorValues.grey30,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusLinear.shopping_cart,
                size: Styles.bigIcon,
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nama Pelanggan",
                    style: context.textTheme.bodyMediumBold,
                  ),
                  const SizedBox(
                    height: Styles.smallSpacing,
                  ),
                  Text(
                    "24/04/2024 13:00",
                    style: context.textTheme.bodySmallGrey,
                  ),
                ],
              ),
            ),
            GestureDetector(
              child: Icon(
                IconsaxPlusLinear.arrow_right_3,
                size: Styles.defaultIcon,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
