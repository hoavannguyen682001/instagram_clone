import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_screen_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _bioController.dispose();
    _userNameController.dispose();
  }

  // Uint8List convertStringToUint8List(String str) {
  //   final List<int> codeUnits = str.codeUnits;
  //   final Uint8List unit8List = Uint8List.fromList(codeUnits);
  //
  //   return unit8List;
  // }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passController.text,
        username: _userNameController.text,
        bio: _bioController.text,
        file: _image!
    );

    if (res != 'Success') {
      // ignore: use_build_context_synchronously
      showSnackBar(res, context);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          webScreenLayout: WebScreenLayout(),
          mobileScreenLayout: MobileScreenLayout(),
        ),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigatorLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
              //circular avatar
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              'https://haycafe.vn/wp-content/uploads/2021/11/Anh-avatar-facebook-chat-bua-hai-thuoc.jpg'),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 90,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              //text field input username
              TextFieldInput(
                hintText: 'Enter your user name',
                textInputType: TextInputType.text,
                textEditingController: _userNameController,
              ),
              const SizedBox(
                height: 24,
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
              TextFieldInput(
                hintText: 'Enter your bio',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),
              const SizedBox(
                height: 24,
              ),
              //button login
              InkWell(
                onTap: signUpUser,
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
                      : const Text('Sign Up'),
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
                onTap: navigatorLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('Already have an account? '),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Log In',
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
