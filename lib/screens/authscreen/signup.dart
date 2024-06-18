import 'package:cash_counter/model/firestore_model.dart';
import 'package:cash_counter/provider/auth_provider.dart';
import 'package:cash_counter/provider/firestore_provider.dart';
import 'package:cash_counter/screens/authscreen/login.dart';
import 'package:cash_counter/screens/home.dart';
import 'package:cash_counter/service/auth_service.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Widget currentPage = const SignUpPage();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otpCode = TextEditingController();
  bool isLoading = false;

  String? verificationId;
  @override
  void initState() {
    super.initState();
    // checkLogin();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout,
        timeout: Duration(seconds: 120));
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    print("verification completed ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      this.otpCode.text = authCredential.smsCode!;
    });
    if (authCredential.smsCode != null) {
      try {
        UserCredential credential =
            await user!.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await _auth.signInWithCredential(authCredential);
        }
      }
      setState(() {
        isLoading = false;
      });
      // Navigator.pushNamedAndRemoveUntil(
      //     context, Constants.homeNavigate, (route) => false);
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    print(forceResendingToken);
    print("code sent");
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }
  // void checkLogin() async {
  //   String? token = await authClass.getToken();
  //   if (token != null) {
  //     setState(() {
  //       currentPage = const Home();
  //     });
  //   }
  // }

  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool circular = false;
  AuthClass authClass = AuthClass();
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final _auth = ref.watch(authenticationProvider);
        final database = ref.read(databaseProvider);
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonItem(
                      "assets/logo/google.svg", "Continue with Google", 25,
                      () async {
                    await _auth
                        .signInWithGoogle(context)
                        .whenComplete(() async => {
                              await database.createUser(Userdata(
                                _auth.auth.currentUser!.displayName.toString(),
                                _auth.auth.currentUser!.email.toString(),
                              ))
                            });
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Or",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        textItem(
                            "Number",
                            phoneNumber,
                            false,
                            [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            TextInputType.number),
                        const SizedBox(
                          height: 15,
                        ),
                        textItem(
                            "otp",
                            otpCode,
                            false,
                            [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            TextInputType.number),
                        const SizedBox(
                          height: 15,
                        ),
                        // textItem("Password", _passwordController, true, null, null),
                        // const SizedBox(
                        //   height: 15,
                        // ),
                        colorButton("Send Otp"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     const Text(
                  //       "If you already have an Account ?",
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         Navigator.pushAndRemoveUntil(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (builder) => const SignInPage()),
                  //             (route) => false);
                  //       },
                  //       child: const Text(
                  //         " Login",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.white,
                  //           fontSize: 18,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buttonItem(
      String imagePath, String buttonName, double size, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          elevation: 8,
          color: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: Colors.grey,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imagePath,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textItem(
      String name,
      TextEditingController controller,
      bool obsecureText,
      List<TextInputFormatter>? textformatter,
      TextInputType? keyboardType) {
    return Container(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: obsecureText,
        inputFormatters: textformatter,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: name,
          labelStyle: const TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.amber,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget colorButton(
    String name,
  ) {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            isLoading = true;
          });
          await phoneSignIn(phoneNumber: phoneNumber.text);
        }
        // setState(() {
        //   circular = true;
        // });
        // try {
        //   firebase_auth.UserCredential userCredential =
        //       await firebaseAuth.createUserWithEmailAndPassword(
        //           email: _emailController.text,
        //           password: _passwordController.text);
        //   print(userCredential.user?.email);
        //   setState(() {
        //     circular = false;
        //   });
        //   Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(builder: (builder) => const Home()),
        //       (route) => false);
        // } catch (e) {
        //   final snackbar = SnackBar(content: Text(e.toString()));
        //   ScaffoldMessenger.of(context).showSnackBar(snackbar);
        //   setState(() {
        //     circular = false;
        //   });
        // }
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [
            Color(0xFFFD746C),
            Color(0xFFFF9068),
            Color(0xFFFD746C),
          ]),
        ),
        child: Center(
          child: circular
              ? const CircularProgressIndicator()
              : Text(name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
        ),
      ),
    );
  }
}
