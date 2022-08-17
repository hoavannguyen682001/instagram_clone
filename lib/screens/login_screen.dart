import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passController.text);

    if (res == 'Success') {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          webScreenLayout: WebScreenLayout(),
          mobileScreenLayout: MobileScreenLayout(),
        ),
      ));
    } else {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(res, context);
    }
  }

  void navigatorSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(
                flex: 2,
              ),
              //svg image logo
              SvgPicture.asset(
                'assets/images/ic_instagram.svg',
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(
                height: 64,
              ),
              //text field input email
              TextFieldInput(
                hintText: 'Enter your email',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(
                height: 24,
              ),
              //text field input password
              TextFieldInput(
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                textEditingController: _passController,
                isPass: true,
              ),
              const SizedBox(
                height: 24,
              ),
              //button login
              InkWell(
                onTap: loginUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    color: blueColor,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Log In'),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Spacer(
                flex: 2,
              ),
              //transitioning to signing up
              GestureDetector(
                onTap: navigatorSignUp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('Don\'t have an account? '),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
