import 'package:firstapp/constants/routes.dart';
import 'package:firstapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State <VerifyEmailView> createState() =>  VerifyEmailViewState();
}

class  VerifyEmailViewState extends State <VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify email')),
      body: Column(
        children: [ 
          const Text('We have already sent you a verification email. Please open it to verify your account'),
          const Text('If you have not received a verification email, press the button below'),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            }, 
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}