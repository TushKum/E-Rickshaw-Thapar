/// The institute email domain passengers must sign up with.
///
/// Keep in sync with isThaparEmail() in firestore.rules — this copy only
/// exists to fail fast in the UI. The rules are the enforcement: Firebase Auth
/// will mint an account for any address, and nothing stops someone calling the
/// REST API directly, so a client-side check alone stops honest users only.
const String kCampusEmailDomain = '@thapar.edu';

final RegExp _campusEmail = RegExp(
  r'^[^@\s]+@thapar\.edu$',
  caseSensitive: false,
);

bool isThaparEmail(String email) => _campusEmail.hasMatch(email.trim());
