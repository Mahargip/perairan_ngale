import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';

@RoutePage()
class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _noTelponController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          title: Center(
            child: Text(
              'Silakan isi data diri Anda',
              style: context.textTheme.titleLarge,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildNameField(),
                  _buildNomorTelpon(),
                  _buildAlamatField(),
                  _buildRTField(),
                  _buildRWField(),
                  const SizedBox(height: Styles.defaultSpacing),
                  _buildDoneButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      maxCharacter: 50,
      controller: _nameController,
      hintText: "Masukkan nama Anda",
      fillColor: ColorValues.white,
      label: "Nama",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildNomorTelpon() {
    return CustomTextField(
      maxCharacter: 13,
      controller: _noTelponController,
      hintText: "Masukkan Nomor Telpon Anda",
      fillColor: ColorValues.white,
      label: "Nomor Telpon",
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nomor telpon tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildAlamatField() {
    return CustomTextField(
      maxCharacter: 50,
      controller: _addressController,
      hintText: "Masukkan alamat Anda",
      fillColor: ColorValues.white,
      label: "Alamat",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Alamat tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildRTField() {
    return CustomTextField(
      maxCharacter: 2,
      controller: _rtController,
      hintText: "Masukkan RT Anda",
      fillColor: ColorValues.white,
      label: "RT",
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'RT tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildRWField() {
    return CustomTextField(
      maxCharacter: 2,
      controller: _rwController,
      hintText: "Masukkan RW Anda",
      fillColor: ColorValues.white,
      label: "RW",
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'RW tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDoneButton() {
    return CustomButton(
      backgroundColor: Colors.blue,
      text: "Lanjutkan",
      width: double.infinity,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _saveUserDataToFirestore();
          AutoRouter.of(context).replace(HomeWrapperRoute());
        }
      },
    );
  }

  Future<void> _saveUserDataToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final collectionRef = FirebaseFirestore.instance.collection('Customer');
      final count = await collectionRef.count().get();
      final countValue = count.count;
      String counts = '$countValue';
      if (user != null) {
        String userId = user.uid;
        await FirebaseFirestore.instance
            .collection('Customer')
            .doc(userId)
            .set({
          'nama': _nameController.text,
          'alamat': _addressController.text,
          'rt': _rtController.text,
          'rw': _rwController.text,
          'noTelpon': _noTelponController.text,
          'customer_no': _rtController.text + _rwController.text + counts
        });
        print('Data pelanggan berhasil disimpan di Firestore.');
      } else {
        print('Tidak ada pengguna yang sedang login.');
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
