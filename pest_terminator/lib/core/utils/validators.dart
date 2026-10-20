// For login

class Validators {
  Validators._();

  // Requires "@" and ".com" in the email address
  static final RegExp _email = RegExp(
    r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)*\.com$',
    caseSensitive: false,
  );

  static const int minPassLen = 8;

  static String? email(String? value) {
    final v = value?.trim() ?? '';

    // Check if email is empty or not valid
    if (v.isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';

    // Check if password is empty or < 8 chars
    if (v.isEmpty) return 'Enter your password';
    if (v.length < minPassLen) {
      return 'Password must be at least $minPassLen characters';
    }
    return null;
  }
}