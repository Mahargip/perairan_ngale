// ignore_for_file: unused_import

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/models/auth.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/app_text_styles.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/auth_utils.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:perairan_ngale/widgets/custom_gesture_unfocus.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  late bool _isObscure = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // ignore: unnecessary_null_comparison
      if (userCredential != null) {
        User? user = userCredential.user;
        if (user != null) {
          if (await isAdmin(user.uid)) {
            AutoRouter.of(context).replace(AdminMenuRoute());
            return;
          } else if (await isEmployee(user.uid)) {
            AutoRouter.of(context).replace(EmployeeHomeRoute());
            return;
          } else if (await isCustomer(user.uid)) {
            AutoRouter.of(context).replace(CustomerHomeRoute());
            return;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal. Silakan coba lagi.")),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Email atau kata sandi salah. Silakan coba lagi.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _googleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Customer')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          AutoRouter.of(context).replace(CustomerFormRoute());
        } else {
          if (await isAdmin(user.uid)) {
            // AutoRouter.of(context).replace(AdminHomeRoute());
            return;
          } else if (await isEmployee(user.uid)) {
            AutoRouter.of(context).replace(EmployeeHomeRoute());
            return;
          } else if (await isCustomer(user.uid)) {
            AutoRouter.of(context).replace(CustomerHomeRoute());
            return;
          }
        }
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Login dengan Google gagal. Silakan coba lagi.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomGestureUnfocus(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: svg.Svg('assets/bg_loginregis.svg'),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 140.0),
              child: _buildLoginForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Masuk",
                    style: AppTextStyles.style(context).titleLarger,
                  ),
                  Text(
                    "Masukkan email untuk masuk ke akunmu!",
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
                  controller: _emailController,
                  hintText: "Email",
                  fillColor: ColorValues.white,
                  prefixIcon: IconsaxPlusLinear.sms,
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
                    controller: _passwordController,
                    hintText: "Kata sandi",
                    fillColor: ColorValues.white,
                    prefixIcon: IconsaxPlusLinear.key,
                    suffixIcon: _isObscure
                        ? IconsaxPlusLinear.eye
                        : IconsaxPlusLinear.eye_slash,
                    obscureText: _isObscure,
                    suffixIconOnPressed: _toggleObscureText,
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
              child: _isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(
                      text: "Masuk",
                      backgroundColor: ColorValues.primary50,
                      textColor: ColorValues.white,
                      width: double.infinity,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await _login();
                        setState(() {
                          _isLoading = false;
                        });
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Styles.defaultPadding),
              child: Column(
                children: [
                  Text(
                    "Atau masuk dengan",
                    style: AppTextStyles.style(context).bodySmall,
                  ),
                  SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: _googleSignIn,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: Styles.defaultPadding),
                      child: Container(
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/google_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun? Yuk",
                    style: AppTextStyles.style(context).bodySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      AutoRouter.of(context).replace(RegisterRoute());
                    },
                    child: Text("Daftar!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
