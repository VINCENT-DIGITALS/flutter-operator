import 'package:administrator/components/loading.dart';
import 'package:administrator/operator_pages/operator_dashboard_page.dart';
import 'package:administrator/services/database_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/components/my_button.dart';
//test line
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  String errorMessage = '';

  void signUserIn() async {
    LoadingIndicatorDialog().show(context);

    try {
      // Attempt to sign in the user
      String? user = await _authService.signInWithEmail(
        emailController.text,
        passwordController.text,
      );

      // If user is null, sign in failed
      if (user != null) {
        // Display the error message in a toast
        Fluttertoast.showToast(
          msg: user,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        // setState(() {
        //   errorMessage = 'Incorrect email or password. Please try again.';
        // });
      } else {
        // Sign in successful, navigate to HomePage

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors
      setState(() {
        errorMessage = 'Incorrect email or password. Please try again.';
      });
    } finally {
      LoadingIndicatorDialog().dismiss();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = 'lib/images/LOGO.png'; // logo
    String logoDesc = 'lib/images/LOGODESC.png';
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges(),
        builder: (context, snapshot) {
          // If user is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          // If user is not logged in
          else {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 750) {
                    // For larger screens, position the form on the right half
                    return Column(
                      children: [
                        // Add other widgets above the Row if needed
                        // Padding(
                        //   padding:
                        //       const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        //   child: Image.asset(
                        //     logoDesc,
                        //     width: constraints.maxWidth *
                        //         0.5, // Adjust width based on screen size
                        //     height: constraints.maxHeight *
                        //         0.5, // Adjust height based on screen size
                        //   ),
                        // ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  child: Image.asset(
                                    'lib/images/BAYANiLOGO.png',
                                    width: constraints.maxWidth *
                                        0.5, // Adjust width based on screen size
                                    height: constraints.maxHeight *
                                        0.5, // Adjust height based on screen size
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: _buildLoginForm(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add other widgets below the Row if needed
                      ],
                    );
                  } else {
                    // For smaller screens, position the form and image in the center
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Add the logoDesc image at the top
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                'lib/images/LOGODESC.png',
                                width: MediaQuery.of(context).size.width *
                                    0.5, // Adjust width based on screen size
                                height: MediaQuery.of(context).size.height *
                                    0.2, // Adjust height based on screen size
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsetsDirectional.fromSTEB(
                            //       0, 0, 0, 0),
                            //   child: Image.asset(
                            //     imagePath,
                            //     width: MediaQuery.of(context).size.width *
                            //         0.5, // Adjust width based on screen size
                            //     height: MediaQuery.of(context).size.height *
                            //         0.2, // Adjust height based on screen size
                            //   ),
                            // ),
                            _buildLoginForm(),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const AutoSizeText(
                'ADMNISTRATION',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF14181B),
                  fontSize: 25,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: Icon(
                        Icons.person,
                        size: 100,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'Log In',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromARGB(255, 0, 0, 0),
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                      child: TextFormField(
                        controller: emailController,
                        autofocus: false,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                          ),
                          alignLabelWithHint: false,
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF018203),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                      child: TextFormField(
                        controller: passwordController,
                        autofocus: false,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                          ),
                          alignLabelWithHint: false,
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF018203),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFFF5963), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          suffixIcon: InkWell(
                            onTap: () => setState(() {
                              _passwordVisible = !_passwordVisible;
                            }),
                            focusNode: FocusNode(skipTraversal: true),
                            child: Icon(
                              _passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF57636C),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              errorMessage,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 8,
                              stepGranularity: 1,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.red,
                                fontSize: 11,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle the forgot password action
                            },
                            child: const Text(
                              'Forgot your password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 13, 102, 227),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: MyButton(
                        text: 'Sign In',
                        onTap: signUserIn, //Sign in Button
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
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
