import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/app_text_styles.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  late bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );

        if (userCredential != null) {
          AutoRouter.of(context).replace(CustomerFormRoute());
          return;
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          _showErrorDialog('Email sudah terdaftar. Silakan gunakan email lain atau masuk.');
        } else {
          _showErrorDialog('Pendaftaran gagal. Silakan coba lagi.');
        }
      } catch (error) {
        print("Error: $error");
        _showErrorDialog('Terjadi kesalahan. Silakan coba lagi.');
      }
    }
  }

  void _toggleObscureText() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pendaftaran Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: svg.Svg('assets/bg_loginregis.svg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 140.0),
            child: _buildRegisterForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daftar",
                      style: AppTextStyles.style(context).titleLarger,
                    ),
                    Text(
                      "Masukkan email, dan buat password untuk mendaftar!",
                      style: AppTextStyles.style(context).bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: AppTextStyles.style(context).titleSmall,
                  ),
                  SizedBox(height: 8.0),
                  CustomTextField(
                    controller: _controllerEmail,
                    hintText: "Email",
                    fillColor: ColorValues.white,
                    prefixIcon: IconsaxPlusLinear.sms,
                    onChanged: (s) {},
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kata sandi",
                      style: AppTextStyles.style(context).titleSmall,
                    ),
                    SizedBox(height: 8.0),
                    CustomTextField(
                      controller: _controllerPassword,
                      hintText: "Kata sandi",
                      fillColor: ColorValues.white,
                      prefixIcon: IconsaxPlusLinear.key,
                      suffixIcon: _isObscure ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                      obscureText: _isObscure,
                      suffixIconOnPressed: _toggleObscureText,
                      onChanged: (s) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi tidak boleh kosong';
                        } else if (value.length < 6) {
                          return 'Kata sandi harus minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(),
                child: CustomButton(
                  text: "Daftar",
                  backgroundColor: ColorValues.primary50,
                  textColor: ColorValues.white,
                  width: double.infinity,
                  onPressed: _register,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun? Yuk",
                      style: AppTextStyles.style(context).bodySmall,
                    ),
                    TextButton(
                      onPressed: () {
                        AutoRouter.of(context).replace(LoginRoute());
                      },
                      child: Text("Masuk!"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
