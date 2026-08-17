import 'package:erickshaw/screens/select_route.dart';
import 'package:flutter/material.dart';

import 'email_verification_view.dart';

class EmailVerification_Passenger extends StatelessWidget {
  const EmailVerification_Passenger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmailVerificationView(
      roleLabel: 'start requesting rides',
      destination: (_) => const SelectRoute(),
    );
  }
}
