import 'package:billova/main.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/view/auth/login_page.dart';
import 'package:billova/view/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectAuthPage extends StatefulWidget {
  const SelectAuthPage({super.key});

  @override
  State<SelectAuthPage> createState() => _SelectAuthPageState();
}

class _SelectAuthPageState extends State<SelectAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: mq.height * 0.70,
                // color: Colors.grey[400],
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/images/billova_logo.png'),
                  ),
                ),
              ),
              sh30,
              Padding(
                padding: const EdgeInsets.all(10),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Hero(
                      tag: 'regbtn',
                      child: CustomButtons(
                        onPressed: () {
                          Get.to(
                            () => const RegisterPage(),
                            duration: const Duration(milliseconds: 600),
                            transition: Transition.fade,
                          );
                        },
                        text: Text(
                          'Register',
                          style: TextStyle(fontSize: mq.width * .040),
                        ),
                      ),
                    ),
                    sh20,
                    Hero(
                      tag: 'logbtn',
                      child: CustomButtons(
                        onPressed: () {
                          Get.to(
                            () => const LoginPage(),
                            duration: const Duration(milliseconds: 600),
                            transition: Transition.fade,
                          );
                        },
                        text: Text(
                          'Sign In',
                          style: TextStyle(fontSize: mq.width * .040),
                        ),
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
