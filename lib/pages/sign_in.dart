import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import '/widgets/sign_in_form.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(title: 'Repair App'),

          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(padding: EdgeInsets.all(16.0), child: SignInForm()),
            ]),
          ),
        ],
      ),
    );
  }
}
