import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Maps a FirebaseAuthException to something a student can act on.
///
/// Was duplicated verbatim in login.dart, login_driver.dart, customer.dart and
/// driversign.dart, each with a slightly different set of cases.
String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'invalid-credential':
    case 'wrong-password':
      return 'Wrong email or password.';
    case 'user-not-found':
      return 'No account found for that email.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'email-already-in-use':
      return 'An account already exists for that email.';
    case 'weak-password':
      return 'Pick a longer password — at least 6 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a moment and try again.';
    case 'operation-not-allowed':
      return 'Email sign-in is turned off for this project.';
    case 'network-request-failed':
      return 'No connection. Check your network and try again.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

void showAuthError(BuildContext context, FirebaseAuthException error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(authErrorMessage(error)),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
}
