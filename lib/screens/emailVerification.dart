import 'package:erickshaw/screens/driver_card/DriverOptions.dart';
import 'package:flutter/material.dart';

import 'email_verification_view.dart';

class EmailVerification_Driver extends StatelessWidget {
  const EmailVerification_Driver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmailVerificationView(
      roleLabel: 'start accepting ride requests',
      destination: (_) => const DriverOptions(),
    );
  }
}
